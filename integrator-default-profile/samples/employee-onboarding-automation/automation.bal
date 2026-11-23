import ballerina/log;
import ballerina/task;

// Polls Gmail inbox every 60 seconds for new acceptance emails.
listener task:Listener gmailPoller = new (trigger = {interval: 60});

service "acceptance-poller" on gmailPoller {
    isolated function execute() returns error? {
        log:printInfo("Polling Gmail for acceptance emails...");
        string|error result = acceptanceAgent.run(
            "Check unread emails for job offer acceptances and provision workspace accounts."
        );
        if result is error {
            log:printError("Acceptance agent error", 'error = result);
        } else {
            log:printInfo("Acceptance agent completed", result = result);
        }
    }
}
