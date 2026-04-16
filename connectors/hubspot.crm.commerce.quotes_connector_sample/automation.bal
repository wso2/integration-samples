import ballerina/log;
import ballerinax/hubspot.crm.commerce.quotes;

public function main() returns error? {
    do {
        quotes:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging result = check quotesClient->/.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
