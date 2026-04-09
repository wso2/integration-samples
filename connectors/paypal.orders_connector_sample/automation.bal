import ballerina/log;
import ballerinax/paypal.orders;

public function main() returns error? {
    do {
        orders:Order ordersOrder = check ordersClient->/orders.post({purchase_units: [], intent: "CAPTURE"});
        log:printInfo(ordersOrder.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
