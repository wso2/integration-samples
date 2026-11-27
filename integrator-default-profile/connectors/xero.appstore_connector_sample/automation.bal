import ballerina/log;
import ballerinax/xero.appstore;

public function main() returns error? {
    do {
        appstore:Subscription subscription = check appstoreClient->getSubscription(string `${appstoreSubscriptionId}`);
        log:printInfo(subscription.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
