import ballerina/log;
import ballerinax/sap.successfactors.ecskillsmanagement;

public function main() returns error? {
    do {
        ecskillsmanagement:Wrapper ecskillsmanagementWrapper = check ecskillsmanagementClient->listCertificationContents();
        log:printInfo(ecskillsmanagementWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
