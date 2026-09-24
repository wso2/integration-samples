import ballerina/log;
import ballerinax/sap.successfactors.ecworkflow;

public function main() returns error? {
    do {
        ecworkflow:Wrapper ecworkflowWrapper = check ecworkflowClient->listMyPendingWorkflows();
        log:printInfo(ecworkflowWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
