import ballerina/log;
import ballerinax/googleapis.sheets;

public function main() returns error? {
    do {
        check sheetsClient->appendRowToSheet(sheetsSpreadsheetId, "Sheet1", ["John Doe", "john@example.com", "42"]);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
