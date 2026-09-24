import ballerina/log;
import ballerinax/sap.successfactors.employeecentralec;

public function main() returns error? {
    do {
        employeecentralec:Wrapper employeecentralecWrapper = check employeecentralecClient->listPerGlobalInfoAREs();
        log:printInfo(employeecentralecWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
