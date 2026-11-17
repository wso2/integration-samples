import ballerina/http;
import ballerina/log;
import ballerina/task;
import ballerina/time;
import ballerinax/googleapis.gmail;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /email\-header\-analyzer on httpDefaultListener {
    resource function post analyze(@http:Payload json payload) returns record {|
        *http:Ok;
        EmailSecurityReport body;
        "application/json" mediaType = "application/json";
        record {|
            (string|int|boolean|string[]|int[]|boolean[])...;
        |} headers?;
    |}|error {
        do {
            json result = check emailSecurityAgent.run(`Analyze the emails described in this request and return a list with one analysis per email.

Request:
${payload.toJsonString()}`);
            return {body: check result.cloneWithType(EmailSecurityReport)};
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}

// Checks the inbox for new emails on a schedule and asks the agent to analyze them.
// Note: the WSO2 default model provider token expires 1 hour after you click Run. After that, model calls fail
// until you stop the integration and click Run again (debug Restart keeps the old token). See README.md.
listener task:Listener inboxPoller = new (trigger = {
    interval: pollIntervalSeconds,
    taskPolicy: {errorPolicy: task:LOG_AND_CONTINUE, waitingPolicy: task:IGNORE}
});

// Time of the last check, in seconds since the epoch. Starts at startup, so only emails that arrive after that are analyzed.
isolated int lastPollTime = time:utcNow()[0];
// IDs of emails that were already analyzed, with the time they were analyzed, so overlapping checks skip them.
isolated map<int> analyzedEmails = {};

service on inboxPoller {
    isolated function execute() returns error? {
        int now = time:utcNow()[0];
        int since;
        lock {
            since = lastPollTime;
            lastPollTime = now;
        }
        // Look back two extra minutes, because Gmail can index an email a little after it arrives.
        gmail:ListMessagesResponse response = check gmailClient->/users/["me"]/messages.get(q = string `${pollQuery} after:${since - 120}`);
        readonly & string[] foundIds = from gmail:Message message in response.messages ?: []
            select message.id;

        readonly & string[] newIds;
        lock {
            string[] fresh = [];
            foreach string id in foundIds {
                if !analyzedEmails.hasKey(id) {
                    analyzedEmails[id] = now;
                    fresh.push(id);
                }
            }
            foreach [string, int] [id, analyzedAt] in analyzedEmails.entries() {
                if now - analyzedAt > 3600 {
                    _ = analyzedEmails.remove(id);
                }
            }
            newIds = fresh.cloneReadOnly();
        }
        if newIds.length() == 0 {
            return;
        }

        log:printInfo("New emails received", count = newIds.length());
        json result = check emailSecurityAgent.run(string `Analyze the emails with these Gmail message IDs: ${string:'join(", ", ...newIds)}`);
        EmailSecurityReport report = check result.cloneWithType();
        foreach EmailHeaderAnalysis email in report.emails {
            string summary = string `${email.spoofingRisk} spoofing risk: "${email.subject}" from ${email.sender}`;
            if email.spoofingRisk == "LOW" {
                log:printInfo(summary, analysis = email.toJson());
            } else {
                log:printWarn(summary, analysis = email.toJson());
            }
        }
    }
}
