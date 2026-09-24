import ballerina/log;
import ballerinax/sap.successfactors.eccompensationinformation;

public function main() returns error? {
    do {
        eccompensationinformation:Wrapper eccompensationinformationWrapper = check eccompensationinformationClient->listOneTimeDeductions();
        log:printInfo(eccompensationinformationWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
