import ballerina/log;
import ballerinax/jira.servicemanagement;

public function main() returns error? {
    do {
        servicemanagement:PagedDTOServiceDeskDTO serviceDesks = check servicemanagementClient->getServiceDesks();
        log:printInfo(serviceDesks.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
