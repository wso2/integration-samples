import ballerina/log;

public function main() returns error? {
    log:printInfo("Starting Trello Card Summary Automation");
    log:printInfo(string `Grouping: ${summaryConfig.grouping.toString()}`);
    log:printInfo(string `Mailchimp List: ${mailchimpConfig.listId}`);

    check sendTrelloSummary();
}
