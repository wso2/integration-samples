import ballerina/log;
import ballerinax/googleapis.sheets as sheets;


string[] columns = ["Id", "Name", "Amount", "OwnerId", "LastActivityDate", "Description", "Probability", "NextStep"];

public function main() returns error? {
    do { 
        string spreadSheetName = string `Opportunities ${check getFormattedCurrentTimeStamp()}`;

        sheets:Spreadsheet spreadsheet = check sheetsClient->createSpreadsheet(spreadSheetName);

        log:printInfo("Spreadsheet created with name: " + spreadSheetName);
        _ = check sheetsClient->appendValue(spreadsheet.spreadsheetId, columns, {
            sheetName: spreadsheet.sheets[0].properties.title
        });

        stream<Opportunity, error?> opportunities = check salesforceClient->query("SELECT FIELDS(STANDARD) FROM Opportunity");

        string [][] values = check from Opportunity account in opportunities select mapOpportunityToRow(account);
        _ = check sheetsClient->appendValues(
            spreadsheet.spreadsheetId, 
            values, 
            { 
                sheetName: spreadsheet.sheets[0].properties.title 
            },
            sheets:USER_ENTERED
        );

        log:printInfo(`${values.length()} ${values.length() == 1 ? "opportunity" : "opportunities"} added to the spreadsheet successfully.`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
