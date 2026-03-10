import ballerina/log;
import ballerina/task;

// Job to send Trello summary
class TrelloSummaryJob {

    *task:Job;

    public function execute() {
        error? result = sendTrelloSummary();
        if result is error {
            log:printError("Failed to send Trello summary", 'error = result);
        } else {
            log:printInfo("Trello summary sent successfully");
        }
    }
}

// Main function to send Trello summary
function sendTrelloSummary() returns error? {
    log:printInfo("Starting Trello summary generation...");

    // Fetch cards
    CardSummary[] cards = check fetchTrelloCards();
    log:printInfo(string `Fetched ${cards.length().toString()} cards`);

    if cards.length() == 0 {
        log:printInfo("No cards found matching the criteria. Skipping email.");
        return;
    }

    // Count overdue cards
    int overdueCount = countOverdueCards(cards);

    // Group cards
    GroupedSummary[] groupedSummaries = groupCards(cards);
    log:printInfo(string `Grouped cards into ${groupedSummaries.length().toString()} groups`);

    // Generate email content
    string emailContent = generateEmailContent(groupedSummaries, cards.length(), overdueCount);

    // Send email
    check sendEmailSummary(emailContent);
    log:printInfo("Email sent successfully");
}

// Parse cron expression and convert to frequency in seconds
function parseCronToFrequency(string cron) returns decimal|error {
    // Simple cron parser for common patterns
    // Format: minute hour day month dayOfWeek
    string[] parts = re ` `.split(cron);

    if parts.length() != 5 {
        return error("Invalid cron expression format");
    }

    string minutePart = parts[0];
    string hourPart = parts[1];

    // For simplicity, calculate based on daily frequency
    // This is a basic implementation - for production use a proper cron library
    if minutePart == "*" && hourPart == "*" {
        return 3600; // Every hour
    } else if minutePart != "*" && hourPart == "*" {
        return 3600; // Every hour at specific minute
    } else {
        return 86400; // Daily
    }
}
