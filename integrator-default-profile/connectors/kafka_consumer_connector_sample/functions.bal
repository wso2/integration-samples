import ballerina/log;

public isolated function processOrder(OrderEvent orderEvent) {
    // TODO: Implement the logic to process the order
    log:printInfo("Processing order..", orderId = orderEvent.orderId);
}