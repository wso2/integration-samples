import ballerina/http;
import ballerina/log;
import ballerina/task;
import ballerina/time;
import ballerinax/googleapis.gmail;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /email\-header\-analyzer on httpDefaultListener {
    resource function post analyze(@http:Payload AnalyzeRequest request) returns record {|
        *http:Ok;
        EmailSecurityReport body;
        "application/json" mediaType = "application/json";
        record {|
            (string|int|boolean|string[]|int[]|boolean[])...;
        |} headers?;
    |}|error {
        do {
            // Only the validated message IDs or search query reach the agent, never the raw request body.
            string[]? messageIds = request.messageIds;
            string prompt;
            if messageIds is string[] && messageIds.length() > 0 {
                foreach string id in messageIds {
                    if !re `[0-9A-Za-z]{1,64}`.isFullMatch(id) {
                        return error(string `Invalid Gmail message ID: ${id}`);
                    }
                }
                prompt = string `Analyze the emails with these Gmail message IDs: ${string:'join(", ", ...messageIds)}`;
            } else {
                string query = request.query ?: DEFAULT_QUERY;
                if query.length() > 200 || query.includes("\n") {
                    return error("The query must be a single-line Gmail search query of at most 200 characters");
                }
                prompt = string `Analyze the emails that match this Gmail search query: ${query}`;
            }
            json result = check emailSecurityAgent.run(prompt);
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
        // Look back two extra minutes, because Gmail can index an email a little after it arrives. Read every page,
        // so that no email is skipped after an outage or a burst of email.
        string query = string `${pollQuery} after:${since - 120}`;
        string[] ids = [];
        string? pageToken = ();
        while true {
            gmail:ListMessagesResponse response = check gmailClient->/users/["me"]/messages.get(q = query,
                pageToken = pageToken);
            foreach gmail:Message message in response.messages ?: [] {
                ids.push(message.id);
            }
            pageToken = response.nextPageToken;
            if pageToken is () {
                break;
            }
        }
        readonly & string[] foundIds = ids.cloneReadOnly();

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
