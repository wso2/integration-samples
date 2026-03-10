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

string currentTimeStamp = check getFormattedCurrentTimeStamp();

public function runAutomation() returns error? {

     do {
         string jql = string `project=${jiraProjectKey}`;
         string prefix = "Jira Issues";
         string spreadSheetName = string `${prefix} ${currentTimeStamp}`;

         log:printInfo("Executing JQL: " + jql);

         jira:SearchAndReconcileResults result = check jiraClient->/api/'3/search/jql(
             jql = jql,
             fields = ["summary", "status", "assignee", "created", "duedate"]
         );

         log:printInfo("Raw result: " + result.toString());

         jira:IssueBean[]? issueBeans = result.issues;
         
         if issueBeans is () {
             log:printWarn("No issues found in the Jira project.");
             return;
         }

         // Convert IssueBean[] to IssueData[]
         IssueData[] issues = from jira:IssueBean bean in issueBeans
                              select convertBeanToIssueData(bean);

         SheetRow[] issueValues =
             from IssueData issue in issues
             select mapIssueToRow(issue);

         SheetRow[] allValues = [columns];
         allValues.push(...issueValues);

         sheets:Sheet sheet;
         string workingSpreadsheetId;
         if spreadsheetId is string {
             workingSpreadsheetId = spreadsheetId ?: "";
             log:printInfo("Using existing spreadsheet with ID: " + workingSpreadsheetId);
             sheet = check sheetsClient->addSheet(workingSpreadsheetId, spreadSheetName);
         } else {
             sheets:Spreadsheet spreadsheet =
                 check sheetsClient->createSpreadsheet(name = spreadSheetName);

             log:printInfo("Spreadsheet created with name: " + spreadSheetName);

             workingSpreadsheetId = spreadsheet.spreadsheetId;
             sheet = spreadsheet.sheets[0];
         }

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
         log:printError("Error occurred", 'error = e);
         return e;
     }
 }
