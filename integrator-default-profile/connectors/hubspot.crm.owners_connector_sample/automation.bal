import ballerina/log;
import ballerinax/hubspot.crm.owners;

public function main() returns error? {
    do {
        owners:CollectionResponsePublicOwnerForwardPaging result = check ownersClient->/.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
