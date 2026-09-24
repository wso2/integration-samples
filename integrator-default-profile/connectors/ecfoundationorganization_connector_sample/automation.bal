import ballerina/log;
import ballerinax/sap.successfactors.ecfoundationorganization;

public function main() returns error? {
    do {
        ecfoundationorganization:Wrapper ecfoundationorganizationWrapper = check ecfoundationorganizationClient->listFOLegalEntityLocalUSAs();
        log:printInfo(ecfoundationorganizationWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
