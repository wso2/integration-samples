import ballerina/log;
import ballerinax/sap.successfactors.ecglobalassignment;

public function main() returns error? {
    do {
        ecglobalassignment:Wrapper ecglobalassignmentWrapper = check ecglobalassignmentClient->listSecondaryAssignmentsItems();
        log:printInfo(ecglobalassignmentWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
