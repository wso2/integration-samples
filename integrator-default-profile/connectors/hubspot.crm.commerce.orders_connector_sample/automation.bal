import ballerina/log;
import ballerinax/hubspot.crm.commerce.orders;

public function main() returns error? {
    do {
        orders:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging result = check ordersClient->/.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
