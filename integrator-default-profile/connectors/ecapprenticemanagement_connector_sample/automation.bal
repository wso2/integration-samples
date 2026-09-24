import ballerina/log;
import ballerinax/sap.successfactors.ecapprenticemanagement;

public function main() returns error? {
    do {
        ecapprenticemanagement:Wrapper ecapprenticemanagementWrapper = check ecapprenticemanagementClient->listApprenticeEventTypes();
        log:printInfo(ecapprenticemanagementWrapper.toString());

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
