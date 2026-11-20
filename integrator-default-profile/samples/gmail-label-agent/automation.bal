import ballerina/log;
import ballerina/time;
import ballerinax/googleapis.gmail;

// Poll interval in seconds (5 minutes)
const decimal POLL_INTERVAL = 300;

// Only emails that arrive after startup are processed
isolated int lastPollSeconds = time:utcNow()[0];

isolated function pollNewEmails() returns error? {
    int sinceSeconds = 0;
    lock {
        sinceSeconds = lastPollSeconds;
    }
    int pollStartSeconds = time:utcNow()[0];
    // Each poll covers a fixed window that ends where the next one starts, so an email that arrives
    // during this poll waits for the next one. The window starts one second early so an email received
    // exactly on the boundary is never missed.
    string query = string `in:inbox after:${sinceSeconds - 1} before:${pollStartSeconds}`;

    string? pageToken = ();
    gmail:Message[] pending = [];
    while true {
        gmail:ListMessagesResponse page = check gmailClient->/users/me/messages(q = query, maxResults = 50, pageToken = pageToken);
        gmail:Message[] pageMessages = page.messages ?: [];
        pending.push(...pageMessages);
        string? nextToken = page.nextPageToken;
        if nextToken is () {
            break;
        }
        pageToken = nextToken;
    }

    // Advance the window only after the listing succeeded
    lock {
        lastPollSeconds = pollStartSeconds;
    }

    if pending.length() == 0 {
        log:printInfo("No new emails");
        return;
    }
    log:printInfo("Processing new emails", count = pending.length());

    foreach gmail:Message item in pending {
        error? labelResult = labelEmail(item.id);
        if labelResult is error {
            log:printError("Skipped email", messageId = item.id, 'error = labelResult);
            continue;
        }
    }
}

isolated function labelEmail(string messageId) returns error? {
    gmail:Message email = check gmailClient->/users/me/messages/[messageId](format = "full");
    string sender = email.'from ?: "";
    string subject = email.subject ?: "";
    string snippet = email.snippet ?: "";
    string prompt = string `Label this email.
Message id: ${messageId}
From: ${sender}
Subject: ${subject}
Snippet: ${snippet}`;
    string summary = check emailLabelAgent.run(prompt);
    log:printInfo("Email labeled", messageId = messageId, summary = summary);
}
