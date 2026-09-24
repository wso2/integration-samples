import ballerina/log;
import ballerinax/sap.successfactors.ecemployeecentralpayroll;

public function main() returns error? {
    do {
        ecemployeecentralpayroll:Wrapper ecemployeecentralpayrollWrapper = check ecemployeecentralpayrollClient->listEmployeePayrollRunResultsItemss();
        log:printInfo(ecemployeecentralpayrollWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
