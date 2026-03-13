import ballerina/log;

public function main() returns error? {
    log:printInfo("Starting Jira to Google Sheets automation");
    check runAutomation();
}
