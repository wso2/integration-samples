import ballerina/log;
import ballerinax/googleapis.sheets as sheets;


SheetRow columns = ["Id", "Name", "Amount", "OwnerId", "LastActivityDate", "Description", "Probability %", "NextStep"];
string spreadSheetName = string `Opportunities ${check getFormattedCurrentTimeStamp()}`;

public function main() returns error? {
    do { 

        stream<Opportunity, error?> opportunities = check salesforceClient->query("SELECT FIELDS(STANDARD) FROM Opportunity");

        SheetRow[] opportunityValues = check from Opportunity account in opportunities select mapOpportunityToRow(account);

        if opportunityValues.length() <= 0 {
            log:printWarn("No opportunities are found in the given salesforce account.");
            return;
        }

        SheetRow[] allValues = [columns];
        allValues.push(...opportunityValues);

        sheets:Spreadsheet spreadsheet = check sheetsClient->createSpreadsheet(spreadSheetName);

        log:printInfo("Spreadsheet created with name: " + spreadSheetName);

        _ = check sheetsClient->appendValues(
            spreadsheet.spreadsheetId, 
            allValues, 
            { 
                sheetName: spreadsheet.sheets[0].properties.title 
            }
        );

        log:printInfo(`${opportunityValues.length()} ${opportunityValues.length() == 1 ? "opportunity" : "opportunities"} added to the spreadsheet successfully.`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
