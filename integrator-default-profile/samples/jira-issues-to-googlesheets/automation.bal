import ballerina/log;
import ballerinax/googleapis.sheets as sheets;
import ballerinax/jira;

const SheetRow columns = [
    "Issue Key",
    "Summary",
    "Status",
    "Assignee",
    "Created",
    "Due Date"
];

function getOrCreateSpreadsheet(string sheetName) returns [string, sheets:Sheet]|error {
    string? existingSpreadsheetId = spreadsheetId;
    if existingSpreadsheetId is string {
        log:printInfo("Using existing spreadsheet with ID: " + existingSpreadsheetId);
        sheets:Sheet sheet = check sheetsClient->addSheet(existingSpreadsheetId, sheetName);
        return [existingSpreadsheetId, sheet];
    }
    
    sheets:Spreadsheet spreadsheet = check sheetsClient->createSpreadsheet(name = sheetName);
    log:printInfo("Spreadsheet created with name: " + sheetName);
    return [spreadsheet.spreadsheetId, spreadsheet.sheets[0]];
}

public function sendJiraIssuesToGoogleSheets() returns error? {

     do {
         string currentTimeStamp = check getFormattedCurrentTimeStamp();
         
         string jql;
         string prefix;

         match timeFrame {
             YESTERDAY => {
                 jql = string `project=${jiraConfig.projectKey} AND created >= -1d`;
                 prefix = "New Jira Issues Since Yesterday";
             }
             LAST_WEEK => {
                 jql = string `project=${jiraConfig.projectKey} AND created >= -7d`;
                 prefix = "New Jira Issues Since Last Week";
             }
             LAST_MONTH => {
                 jql = string `project=${jiraConfig.projectKey} AND created >= -30d`;
                 prefix = "New Jira Issues Since Last Month";
             }
             LAST_QUARTER => {
                 jql = string `project=${jiraConfig.projectKey} AND created >= -90d`;
                 prefix = "New Jira Issues Since Last Quarter";
             }
             _ => {
                 jql = string `project=${jiraConfig.projectKey}`;
                 prefix = "Jira Issues";
             }
         }
         string spreadSheetName = string `${prefix} ${currentTimeStamp}`;

         log:printInfo("Time frame selected: " + timeFrame);
         log:printInfo("Executing JQL: " + jql);

         jira:SearchAndReconcileResults result = check jiraClient->/api/'3/search/jql(
             jql = jql,
             fields = ["summary", "status", "assignee", "created", "duedate"]
         );

         jira:IssueBean[]? issueBeans = result.issues;
         if issueBeans is () {
             log:printInfo("No Jira issues found matching the criteria.");
             return;
         }

         IssueData[] issues = from jira:IssueBean bean in issueBeans
                              select convertBeanToIssueData(bean);

         SheetRow[] issueValues =
             from IssueData issue in issues
             select mapIssueToRow(issue);

         SheetRow[] allValues = [columns, ...issueValues];

         [string, sheets:Sheet] [workingSpreadsheetId, sheet] = check getOrCreateSpreadsheet(spreadSheetName);

         sheets:A1Range a1Range = {
             sheetName: sheet.properties.title
         };

         _ = check sheetsClient->appendValues(
             spreadsheetId = workingSpreadsheetId,
             values = allValues,
             a1Range = a1Range
         );

         log:printInfo(string `${issueValues.length()} issue(s) added to the spreadsheet successfully.`);

     } on fail error e {
         log:printError("Error: " + e.message());
         return e;
     }
 }
