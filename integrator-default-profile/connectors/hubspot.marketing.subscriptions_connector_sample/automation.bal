import ballerina/log;
import ballerinax/hubspot.marketing.subscriptions;

public function main() returns error? {
    do {
        subscriptions:ActionResponseWithResultsSubscriptionDefinition result = check subscriptionsClient->getCommunicationPreferencesV4Definitions();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
