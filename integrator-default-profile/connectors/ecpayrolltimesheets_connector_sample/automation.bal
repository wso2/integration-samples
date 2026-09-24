import ballerina/log;
import ballerinax/sap.successfactors.ecpayrolltimesheets;

public function main() returns error? {
    do {
        ecpayrolltimesheets:Wrapper ecpayrolltimesheetsWrapper = check ecpayrolltimesheetsClient->listEmployeeTimeSheets();
        log:printInfo(ecpayrolltimesheetsWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
