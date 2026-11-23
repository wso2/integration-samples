import ballerina/log;
import ballerina/task;

isolated boolean isPolling = false;

isolated function tryAcquirePollingLock() returns boolean {
    lock {
        if isPolling {
            return false;
        }
        isPolling = true;
        return true;
    }
}

isolated function releasePollingLock() {
    lock {
        isPolling = false;
    }
}

listener task:Listener gmailPoller = new (trigger = {interval: 60});

service "acceptance-poller" on gmailPoller {
    isolated function execute() returns error? {
        if !tryAcquirePollingLock() {
            log:printInfo("Acceptance check already in progress, skipping this poll cycle.");
            return;
        }
        do {
            check processAcceptanceEmails();
        } on fail error e {
            log:printError("Acceptance processing error", 'error = e);
        }
        releasePollingLock();
    }
}

isolated function processAcceptanceEmails() returns error? {
    string emailsResult = check fetchUnreadEmails();
    if emailsResult == "NO_UNREAD_EMAILS" {
        log:printInfo("No unread acceptance emails found.");
        return;
    }
    string[] emailLines = re`\n`.split(emailsResult);
    foreach string line in emailLines {
        string[] parts = re`\|`.split(line);
        if parts.length() < 4 {
            continue;
        }
        string messageId = parts[0];
        string senderEmail = parts[1];
        string subject = parts[2];
        // Rejoin remaining parts in case snippet itself contains |
        string snippet = string:'join("|", ...parts.slice(3));

        string|error lookupResult = lookupCandidateByEmail(senderEmail);
        if lookupResult is error {
            log:printError("Lookup failed", email = senderEmail, 'error = lookupResult);
            continue;
        }
        if lookupResult == "NOT_FOUND" || lookupResult == "ALREADY_PROVISIONED" {
            error? markErr = markEmailAsRead(messageId);
            if markErr is error {
                log:printWarn("Could not mark email as read", messageId = messageId, 'error = markErr);
            }
            continue;
        }

        string[] rowParts = re`\|`.split(lookupResult);
        if rowParts.length() < 2 {
            continue;
        }
        string rowNumber = rowParts[0];
        string candidateName = string:'join("|", ...rowParts.slice(1));

        string|error classifyResult = classifyEmailAcceptance(subject, snippet);
        if classifyResult is error || classifyResult != "YES" {
            error? markErr = markEmailAsRead(messageId);
            if markErr is error {
                log:printWarn("Could not mark email as read", messageId = messageId, 'error = markErr);
            }
            continue;
        }

        // Mark in_progress before any side effects to guard against duplicate processing
        _ = check markCandidateInProgress(rowNumber);

        string|error workEmailResult = createWorkspaceAccount(candidateName, senderEmail);
        if workEmailResult is error {
            log:printError("Account creation failed", email = senderEmail, 'error = workEmailResult);
            continue;
        }

        _ = check sendCredentialsEmail(senderEmail, candidateName, workEmailResult);
        _ = check markCandidateProvisioned(rowNumber);
        error? markErr = markEmailAsRead(messageId);
        if markErr is error {
            log:printWarn("Could not mark email as read", messageId = messageId, 'error = markErr);
        }
        log:printInfo("Candidate provisioned", email = senderEmail, row = rowNumber);
    }
}
