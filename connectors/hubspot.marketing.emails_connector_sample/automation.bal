import ballerina/log;
import ballerinax/hubspot.marketing.emails;

public function main() returns error? {
    do {
        emails:CollectionResponseWithTotalPublicEmailForwardPaging emailsResponse = check emailsClient->/.get();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
