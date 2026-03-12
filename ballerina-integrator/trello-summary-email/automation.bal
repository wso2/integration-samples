import ballerina/log;

function sendTrelloSummary() returns error? {
    log:printInfo("Starting Trello summary generation...");

    //Fetch cards
    CardSummary[] cards = check fetchTrelloCards();
    log:printInfo(string `Fetched ${cards.length().toString()} cards`);

    if cards.length() == 0 {
        log:printInfo("No cards found matching the criteria. Skipping email.");
        return;
    }

    int overdueCount = countOverdueCards(cards);

    GroupedSummary[] groupedSummaries = groupCards(cards);
    log:printInfo(string `Grouped cards into ${groupedSummaries.length().toString()} groups`);

    string emailContent = generateEmailContent(groupedSummaries, cards.length(), overdueCount);

    check sendEmailSummary(emailContent);
    log:printInfo("Email sent successfully");
}


