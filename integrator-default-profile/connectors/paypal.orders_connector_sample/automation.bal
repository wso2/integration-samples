import ballerina/log;
import ballerinax/paypal.orders;

public function main() returns error? {
    do {
        orders:Order ordersOrder = check ordersClient->/orders.post({
            intent: "CAPTURE",
            purchase_units: [{amount: {currency_code: "USD", value: "10.00"}}]
        });
        log:printInfo(ordersOrder.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
