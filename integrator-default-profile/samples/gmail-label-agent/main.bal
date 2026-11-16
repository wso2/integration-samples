import ballerina/log;
import ballerina/task;

// Runs every 5 minutes
listener task:Listener gmailPollListener = new (trigger = {interval: POLL_INTERVAL});

// Set while a poll runs, so a slow poll is never overlapped by the next one
isolated boolean pollInProgress = false;

service "gmail-label-poll" on gmailPollListener {
    isolated function execute() returns error? {
        boolean alreadyRunning = false;
        lock {
            alreadyRunning = pollInProgress;
            pollInProgress = true;
        }
        if alreadyRunning {
            // The skipped window is covered by the next poll, because the checkpoint has not moved
            log:printWarn("Previous Gmail poll is still running, skipping this one");
            return;
        }

        error? result = pollNewEmails();
        lock {
            pollInProgress = false;
        }
        if result is error {
            log:printError("Gmail poll failed", 'error = result);
        }
    }
}
