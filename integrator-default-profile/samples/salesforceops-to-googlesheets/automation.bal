import ballerina/log;
import ballerinax/googleapis.sheets as sheets;


SheetRow columns = ["Id", "Name", "Amount", "OwnerId", "LastActivityDate", "Description", "Probability %", "NextStep"];
string currentTimeStamp = check getFormattedCurrentTimeStamp();

public function main() returns error? {
    do {         
        string query = "SELECT FIELDS(STANDARD) FROM Opportunity";
        string prefix = "All Opportunities";

        match timeFrame {
            YESTERDAY => {
                query += " WHERE CreatedDate >= YESTERDAY";
                prefix = "New Opportunities Since Yesterday";
            }
            LAST_WEEK => {
                query += " WHERE CreatedDate >= LAST_WEEK";
                prefix = "New Opportunities Since Last Week";
            }
            LAST_MONTH => {
                query += " WHERE CreatedDate >= LAST_MONTH";
                prefix = "New Opportunities Since Last Month";
            }
            LAST_QUARTER => {
                query += " WHERE CreatedDate >= LAST_QUARTER";
                prefix = "New Opportunities Since Last Quarter";
            }
        }
        string spreadSheetName = string `${prefix} ${currentTimeStamp}`;

        log:printInfo("Time frame selected: " + timeFrame);
        log:printInfo("Executing query: " + query);
        

        stream<Opportunity, error?> opportunities = check salesforceClient->query(query);

        SheetRow[] opportunityValues = check from Opportunity account in opportunities select mapOpportunityToRow(account);

        if opportunityValues.length() <= 0 {
            log:printWarn("No opportunities are found in the given salesforce account.");
            return;
        }

        SheetRow[] allValues = [columns];
        allValues.push(...opportunityValues);

        sheets:Sheet sheet;
        string workingSpreadsheetId;
        if spreadsheetId is string {
            workingSpreadsheetId = spreadsheetId ?: "";
            log:printInfo("Using existing spreadsheet with ID: " + workingSpreadsheetId);
            sheet = check sheetsClient->addSheet(workingSpreadsheetId, spreadSheetName);
        } else {
            sheets:Spreadsheet spreadsheet = check sheetsClient->createSpreadsheet(spreadSheetName);
            log:printInfo("Spreadsheet created with name: " + spreadSheetName);
            workingSpreadsheetId = spreadsheet.spreadsheetId;
            sheet = spreadsheet.sheets[0];
        }

        _ = check sheetsClient->appendValues(
            workingSpreadsheetId, 
            allValues, 
            { 
                sheetName: sheet.properties.title 
            }
        );

        log:printInfo(string `${opportunityValues.length()} ${opportunityValues.length() == 1 ? "opportunity" : "opportunities"} added to the spreadsheet successfully.`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
