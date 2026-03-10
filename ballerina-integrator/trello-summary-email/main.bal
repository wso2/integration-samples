import ballerina/log;
import ballerina/task;

public function main() returns error? {
    log:printInfo("Starting Trello Card Summary Automation");
    log:printInfo(string `Schedule: ${scheduleConfig.cron}`);
    log:printInfo(string `Grouping: ${summaryConfig.grouping.toString()}`);
    log:printInfo(string `Mailchimp List: ${mailchimpConfig.listId}`);

    // Send immediately on startup for testing
    log:printInfo("Sending initial summary immediately for testing...");
    error? initialResult = sendTrelloSummary();
    if initialResult is error {
        log:printError("Failed to send initial summary", 'error = initialResult);
    } else {
        log:printInfo("Initial summary sent successfully");
    }

    // Parse cron schedule to frequency
    decimal frequency = check parseCronToFrequency(scheduleConfig.cron);

    // Schedule the job
    task:JobId jobId = check task:scheduleJobRecurByFrequency(
        job = new TrelloSummaryJob(),
        interval = frequency
    );

    log:printInfo(string `Job scheduled with ID: ${jobId.id.toString()}`);
    log:printInfo("Automation is running. Press Ctrl+C to stop.");

    // Keep the program running
    while true {
        // Sleep to keep the program alive
        // The scheduled job will run in the background
    }
}
