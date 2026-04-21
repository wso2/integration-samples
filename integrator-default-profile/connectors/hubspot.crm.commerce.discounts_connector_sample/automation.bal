import ballerina/log;
import ballerinax/hubspot.crm.commerce.discounts;

public function main() returns error? {
    do {
        discounts:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging listResult = check discountsClient->/.get();
        log:printInfo(listResult.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
