import ballerina/log;

public function main() returns error? {
    OrderEvent sampleOrder = {
        orderId: "ORD-001",
        customerId: "CUST-123",
        amount: 99.99d,
        timestamp: "2026-05-07T16:00:00Z"
    };
    do {
        check kafkaProducer->send({
            topic: string `${kafkaTopic}`,  // use configurable, not a hardcoded string
            value: sampleOrder.toJsonString().toBytes()
        });
        log:printInfo("Order event sent", orderId = sampleOrder.orderId);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}