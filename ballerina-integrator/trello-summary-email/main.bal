import ballerina/log;
import ballerina/lang.runtime;
import ballerina/task;

public function main() returns error? {
    log:printInfo("Starting Trello Card Summary Automation");
    log:printInfo(string `Schedule: ${scheduleConfig.cron}`);
    log:printInfo(string `Grouping: ${summaryConfig.grouping.toString()}`);
    log:printInfo(string `Mailchimp List: ${mailchimpConfig.listId}`);



    task:JobId jobId = check scheduleNextTrelloSummary();

    log:printInfo(string `Job scheduled with ID: ${jobId.id.toString()}`);
    log:printInfo("Automation is running. Press Ctrl+C to stop.");

    while true {
        runtime:sleep(60);
    }
}
