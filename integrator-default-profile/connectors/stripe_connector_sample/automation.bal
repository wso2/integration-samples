import ballerina/log;
import ballerinax/stripe;

public function main() returns error? {
    do {
        stripe:Balance balance = check stripeClient->getBalance();
        log:printInfo(balance.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
