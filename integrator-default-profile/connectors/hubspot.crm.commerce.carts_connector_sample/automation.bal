import ballerina/log;
import ballerinax/hubspot.crm.commerce.carts;

public function main() returns error? {
    do {
        carts:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging result = check cartsClient->/carts.get(queries = {'limit: 10});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
    
}
