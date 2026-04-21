import ballerina/log;
import ballerinax/paypal.payments;

public function main() returns error? {
    do {
        payments:Authorization2 result = check paymentsClient->/authorizations/[string `0VF52814937998046`].get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
