import ballerina/log;
import ballerinax/docusign.monitor;

public function main() returns error? {
    do {
        monitor:StreamResponse eventPage = check monitorClient->getStream(string `${monitorOrganizationId}`);
        log:printInfo(eventPage.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
