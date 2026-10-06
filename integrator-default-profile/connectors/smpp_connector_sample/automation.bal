import ballerina/log;
import ballerina/smpp;

public function main() returns error? {
    do {
        smpp:SubmitResult result = check smppClient->submit({
            destinationAddress: destinationNumber,
            shortMessage: "Hello from WSO2 Integrator!",
            registeredDelivery: smpp:ON_SUCCESS_OR_FAILURE
        });
        log:printInfo("SMS submitted to the SMSC", messageId = result.messageId);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
