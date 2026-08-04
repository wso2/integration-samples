import ballerina/log;
import ballerinax/aws.marketplace.mpm;

public function main() returns error? {
    do {
        mpm:ResolveCustomerResponse ResolveCustomerResponse = check mpmClient->resolveCustomer(registrationToken = registrationToken);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
