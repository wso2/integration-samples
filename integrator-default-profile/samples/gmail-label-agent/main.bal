import ballerina/log;
import ballerina/task;

// Runs every 5 minutes
listener task:Listener gmailPollListener = new (trigger = {interval: POLL_INTERVAL});

service "gmail-label-poll" on gmailPollListener {
    isolated function execute() returns error? {
        error? result = pollNewEmails();
        if result is error {
            log:printError("Gmail poll failed", 'error = result);
        }
    }
}
