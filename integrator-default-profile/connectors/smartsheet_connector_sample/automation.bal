import ballerina/log;
import ballerinax/smartsheet;

public function main() returns error? {
    do {
        smartsheet:AlternateEmailListResponse listSheetsResult = check smartsheetClient->/sheets.get();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
