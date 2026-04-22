import ballerina/log;
import ballerinax/salesforce;

public function main() returns error? {
    do {
        salesforce:CreationResponse result = check salesforceClient->create("Account", {"Name": "Test Account", "Industry": "Technology"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
