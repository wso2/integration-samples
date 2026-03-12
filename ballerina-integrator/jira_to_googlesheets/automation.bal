import ballerinax/googleapis.sheets as sheets;
import ballerinax/jira;
import ballerina/log;

SheetRow columns = [
    "Issue Key",
    "Summary",
    "Status",
    "Assignee",
    "Created",
    "Due Date"
];

function getOrCreateSpreadsheet(string sheetName) returns [string, sheets:Sheet]|error {
    string trimmedId = spreadsheetId.trim();
    if trimmedId != "" {
        log:printInfo("Using existing spreadsheet with ID: " + trimmedId);
        sheets:Sheet sheet = check sheetsClient->addSheet(trimmedId, sheetName);
        return [trimmedId, sheet];
    }
    
    sheets:Spreadsheet spreadsheet = check sheetsClient->createSpreadsheet(name = sheetName);
    log:printInfo("Spreadsheet created with name: " + sheetName);
    return [spreadsheet.spreadsheetId, spreadsheet.sheets[0]];
}

public function runAutomation() returns error? {

     do {
         string currentTimeStamp = check getFormattedCurrentTimeStamp();
         
         string jql = string `project=${jiraConfig.projectKey}`;
         string prefix = "Jira Issues";

         if timeFrame == YESTERDAY {
             jql += " AND created >= -1d";
             prefix = "New Jira Issues Since Yesterday";
         } else if timeFrame == LAST_WEEK {
             jql += " AND created >= -7d";
             prefix = "New Jira Issues Since Last Week";
         } else if timeFrame == LAST_MONTH {
             jql += " AND created >= -30d";
             prefix = "New Jira Issues Since Last Month";
         } else if timeFrame == LAST_QUARTER {
             jql += " AND created >= -90d";
             prefix = "New Jira Issues Since Last Quarter";
         }
         string spreadSheetName = string `${prefix} ${currentTimeStamp}`;

         string selectedTimeFrame = timeFrame.toString();
         log:printInfo("Time frame selected: " + selectedTimeFrame);
         log:printInfo("Executing JQL: " + jql);

         jira:SearchAndReconcileResults result = check jiraClient->/api/'3/search/jql(
             jql = jql,
             fields = ["summary", "status", "assignee", "created", "duedate"]
         );

         jira:IssueBean[]? issueBeans = result.issues;

         IssueData[] issues = [];
         if issueBeans is jira:IssueBean[] {
             if issueBeans.length() == 0 {
                 return error("No Jira issues found. Please verify your Jira configurations.");
             }
             issues = from jira:IssueBean bean in issueBeans
                      select convertBeanToIssueData(bean);
         }

         SheetRow[] issueValues =
             from IssueData issue in issues
             select mapIssueToRow(issue);

         SheetRow[] allValues = [columns];
         allValues.push(...issueValues);

         [string, sheets:Sheet] spreadsheetResult = check getOrCreateSpreadsheet(spreadSheetName);
         string workingSpreadsheetId = spreadsheetResult[0];
         sheets:Sheet sheet = spreadsheetResult[1];

         sheets:A1Range a1Range = {
             sheetName: sheet.properties.title
         };

         _ = check sheetsClient->appendValues(
             spreadsheetId = workingSpreadsheetId,
             values = allValues,
             a1Range = a1Range
         );

         log:printInfo(
             string `${issueValues.length()} ${issueValues.length() == 1 ? "issue" : "issues"} added to the spreadsheet successfully.`
         );

     } on fail error e {
         log:printError("Error: " + e.message());
         return e;
     }
 }
