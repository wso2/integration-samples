import ballerina/log;
import ballerinax/microsoft.excel;

public function main() returns error? {
    do {
        excel:WorksheetCollectionResponse worksheets = check excelClient->listWorksheets(string `${excelDriveId}`, string `${excelDriveItemId}`);
        log:printInfo(worksheets.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
