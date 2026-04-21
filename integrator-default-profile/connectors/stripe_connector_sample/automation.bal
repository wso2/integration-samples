import ballerina/log;
import ballerinax/stripe;

public function main() returns error? {
    do {
        stripe:CustomerResourceCustomerList customerList = check stripeClient->/customers.get();
        log:printInfo(customerList.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
