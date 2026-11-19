import ballerina/lang.regexp;
import ballerina/log;
import ballerina/task;
import ballerinax/googleapis.gmail;

listener task:Listener gmailPollListener = new (trigger = {interval: pollingIntervalSeconds, maxCount: -1});

// Set while a poll runs, so a slow poll is never overlapped by the next one
isolated boolean pollInProgress = false;

service "sales-inquiry-poll-job" on gmailPollListener {
    isolated function execute() returns error? {
        boolean alreadyRunning = false;
        lock {
            alreadyRunning = pollInProgress;
            pollInProgress = true;
        }
        if alreadyRunning {
            // Messages not yet processed stay unread and unlabeled, so the next poll picks them up
            log:printWarn("Previous Gmail poll is still running, skipping this one");
            return;
        }

        error? result = processUnreadSalesInquiries();
        lock {
            pollInProgress = false;
        }
        if result is error {
            log:printError("Failed to process unread sales inquiries", 'error = result);
        }
    }
}

# Lists messages matching the configured Gmail search query and processes each of them.
# Messages already labeled "sales-processed" are always excluded, so a message is handled only once.
# + return - an error if listing messages failed
isolated function processUnreadSalesInquiries() returns error? {
    string query = string `${gmailSearchQuery} -label:sales-processed`;
    log:printInfo("Polling Gmail for sales inquiries", query = query);
    gmail:Message[] messages = [];
    string? pageToken = ();
    while true {
        gmail:ListMessagesResponse page = check gmailClient->/users/me/messages(q = query, pageToken = pageToken);
        gmail:Message[] pageMessages = page.messages ?: [];
        messages.push(...pageMessages);
        pageToken = page.nextPageToken;
        if pageToken is () {
            break;
        }
    }
    if messages.length() == 0 {
        log:printInfo("No matching messages found on this poll");
        return;
    }
    log:printInfo("Found matching message(s)", matchCount = messages.length());
    foreach gmail:Message message in messages {
        log:printInfo("Processing message", messageId = message.id);
        error? processResult = processSalesInquiryMessage(message.id);
        if processResult is error {
            log:printError("Skipped message due to processing failure, leaving it unread for retry",
                    'error = processResult, messageId = message.id);
        }
    }
}

# Loads the full thread for a message and runs the sales assistant agent on it. The agent decides
# whether to reply (and sends the reply itself via the sendEmailReply tool if so). Once the agent
# run completes, the original message is marked as read and labeled, whether or not it replied.
# + messageId - the id of the unread message to process
# + return - an error if any step failed; the caller leaves the message unread in that case
isolated function processSalesInquiryMessage(string messageId) returns error? {
    gmail:Message originalMessage = check gmailClient->/users/me/messages/[messageId](format = "full");
    string senderHeader = originalMessage.'from ?: "";
    if isAutomatedSender(senderHeader) {
        log:printInfo("Skipping message from an automated/no-reply sender", messageId = messageId, sender = senderHeader);
        check markMessageProcessed(messageId);
        return;
    }

    string threadId = originalMessage.threadId;
    gmail:MailThread thread = check gmailClient->/users/me/threads/[threadId](format = "full");
    gmail:Message[]? threadMessages = thread.messages;
    if threadMessages is () || threadMessages.length() == 0 {
        return error(string `Thread ${threadId} had no messages`);
    }

    string senderName = extractSenderName(senderHeader);
    string senderEmail = extractSenderEmail(senderHeader);
    string subject = originalMessage.subject ?: "(no subject)";
    log:printInfo("Running sales assistant agent on inbound message", messageId = messageId, threadId = threadId,
            senderEmail = senderEmail, subject = subject, threadMessageCount = threadMessages.length());

    EmailMessage[] orderedMessages = [];
    foreach gmail:Message threadMessage in threadMessages {
        orderedMessages.push({
            sender: threadMessage.'from ?: "",
            subject: threadMessage.subject ?: "",
            body: extractPlainTextBody(threadMessage),
            date: threadMessage.date ?: ""
        });
    }

    string originalMessageIdHeader = originalMessage.messageId ?: "";

    InboundEmailRequest agentRequest = {
        senderName,
        senderEmail,
        subject,
        threadId,
        originalMessageIdHeader,
        threadMessages: orderedMessages
    };

    string agentSummary = check salesAssistantAgent.run(agentRequest.toJsonString());
    log:printInfo("Agent run completed", messageId = messageId, threadId = threadId, summary = agentSummary);

    check markMessageProcessed(messageId);
    log:printInfo("Marked message as processed", messageId = messageId);
}

# + senderHeader - the raw "From" header value, e.g. "Jane Doe <jane@example.com>"
# + return - true if the sender looks like a no-reply or automated mailbox
isolated function isAutomatedSender(string senderHeader) returns boolean {
    string lowerSender = senderHeader.toLowerAscii();
    return lowerSender.includes("no-reply") || lowerSender.includes("noreply")
        || lowerSender.includes("do-not-reply") || lowerSender.includes("donotreply")
        || lowerSender.includes("mailer-daemon") || lowerSender.includes("automated");
}

# + senderHeader - the raw "From" header value, e.g. "Jane Doe <jane@example.com>"
# + return - the display name portion, or the email address when no display name is present
isolated function extractSenderName(string senderHeader) returns string {
    string:RegExp pattern = re `^\s*"?([^"<]*?)"?\s*<.*>\s*$`;
    regexp:Groups? groups = pattern.findGroups(senderHeader);
    if groups is regexp:Groups {
        regexp:Span? nameSpan = groups[1];
        if nameSpan is regexp:Span {
            string name = nameSpan.substring().trim();
            if name != "" {
                return name;
            }
        }
    }
    return extractSenderEmail(senderHeader);
}

# + senderHeader - the raw "From" header value, e.g. "Jane Doe <jane@example.com>"
# + return - the email address portion
isolated function extractSenderEmail(string senderHeader) returns string {
    string:RegExp pattern = re `<([^>]+)>`;
    regexp:Groups? groups = pattern.findGroups(senderHeader);
    if groups is regexp:Groups {
        regexp:Span? emailSpan = groups[1];
        if emailSpan is regexp:Span {
            return emailSpan.substring().trim();
        }
    }
    return senderHeader.trim();
}

# + message - the Gmail message to extract the plain text body from
# + return - the decoded plain text body, or the snippet if no text/plain part is found
isolated function extractPlainTextBody(gmail:Message message) returns string {
    gmail:MessagePart? payload = message.payload;
    if payload is () {
        return message.snippet ?: "";
    }
    string? body = findPlainTextPart(payload);
    if body is string {
        return body;
    }
    return message.snippet ?: "";
}

# + part - a MIME message part to search, including any nested parts
# + return - the text/plain body data if found within this part or its children
isolated function findPlainTextPart(gmail:MessagePart part) returns string? {
    string? mimeType = part.mimeType;
    if mimeType is string && mimeType.includes("text/plain") {
        string? data = part.data;
        if data is string {
            return data;
        }
    }
    gmail:MessagePart[]? childParts = part.parts;
    if childParts is gmail:MessagePart[] {
        foreach gmail:MessagePart childPart in childParts {
            string? found = findPlainTextPart(childPart);
            if found is string {
                return found;
            }
        }
    }
    return ();
}

# Marks the original message as read and labels it "sales-processed", creating the label if needed.
# + messageId - the id of the message to update
# + return - an error if the update failed
isolated function markMessageProcessed(string messageId) returns error? {
    string processedLabelId = check getOrCreateProcessedLabelId();
    gmail:Message _ = check gmailClient->/users/me/messages/[messageId]/modify.post({
        removeLabelIds: ["UNREAD"],
        addLabelIds: [processedLabelId]
    });
}

# + return - the Id of the "sales-processed" label, creating it first if it does not already exist
isolated function getOrCreateProcessedLabelId() returns string|error {
    gmail:ListLabelsResponse labelsResponse = check gmailClient->/users/me/labels();
    gmail:Label[]? labels = labelsResponse.labels;
    if labels is gmail:Label[] {
        foreach gmail:Label label in labels {
            if label.name == "sales-processed" {
                string? labelId = label.id;
                if labelId is string {
                    return labelId;
                }
            }
        }
    }
    gmail:Label createdLabel = check gmailClient->/users/me/labels.post({name: "sales-processed"});
    string? newLabelId = createdLabel.id;
    if newLabelId is string {
        return newLabelId;
    }
    return error("Failed to create or resolve the sales-processed label id");
}
