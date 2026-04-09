import ballerina/log;
import ballerinax/paypal.invoices;

public function main() returns error? {
    do {
        invoices:Invoices result = check invoicesClient->/invoices.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
