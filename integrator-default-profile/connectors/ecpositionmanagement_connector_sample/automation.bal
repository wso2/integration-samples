import ballerina/log;
import ballerinax/sap.successfactors.ecpositionmanagement;

public function main() returns error? {
    do {
        ecpositionmanagement:Wrapper ecpositionmanagementWrapper = check ecpositionmanagementClient->listPositionRequisitionStatuses();
        log:printInfo(ecpositionmanagementWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
