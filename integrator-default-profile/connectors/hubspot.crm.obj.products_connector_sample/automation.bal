import ballerina/log;
import ballerinax/hubspot.crm.obj.products;

public function main() returns error? {
    do {
        products:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging result = check productsClient->/.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
