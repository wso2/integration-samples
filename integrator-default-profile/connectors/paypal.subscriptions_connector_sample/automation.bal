import ballerina/log;
import ballerinax/paypal.subscriptions;

public function main() returns error? {
    do {
        subscriptions:PlanCollection result = check subscriptionsClient->/plans.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
