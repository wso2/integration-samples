import ballerina/log;
import ballerinax/confluent.cregistry;

public function main() returns error? {
    do {
        int result = check cregistryClient->register("orders-value", "{\\\"type\\\": \\\"record\\\", \\\"name\\\": \\\"Order\\\", \\\"fields\\\": [{\\\"name\\\": \\\"orderId\\\", \\\"type\\\": \\\"string\\\"}, {\\\"name\\\": \\\"amount\\\", \\\"type\\\": \\\"double\\\"}]}");
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
