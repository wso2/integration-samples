import ballerina/log;
import ballerinax/sap.businessone.projects;

public function main() returns error? {
    do {
        projects:ProjectManagementsCollectionResponse projectManagements = check projectsClient->listProjectManagements();
        log:printInfo("Project management records", response = projectManagements);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

