import ballerina/log;
import ballerinax/aws.simpledb;

public function main() returns error? {
    do {
        simpledb:CreateDomainResponse|xml createDomainResult = check simpledbClient->createDomain("inventory");
        log:printInfo("Created the SimpleDB domain: " + createDomainResult.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
