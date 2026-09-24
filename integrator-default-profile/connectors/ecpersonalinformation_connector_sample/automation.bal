import ballerina/log;
import ballerinax/sap.successfactors.ecpersonalinformation;

public function main() returns error? {
    do {
        ecpersonalinformation:Wrapper ecpersonalinformationWrapper = check ecpersonalinformationClient->listPerEmergencyContactss();
        log:printInfo(ecpersonalinformationWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
