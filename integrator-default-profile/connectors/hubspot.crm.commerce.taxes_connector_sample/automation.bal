import ballerina/log;
import ballerinax/hubspot.crm.commerce.taxes;

public function main() returns error? {
    do {
        taxes:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging listResult = check taxesClient->/.get();
        log:printInfo(listResult.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
