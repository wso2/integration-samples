import orderprocessingautomation.ordersdb;

import ballerina/log;

public function main() returns error? {
    do {
        PlacedOrdersType[] placedOrders = check ordersDB->/orders.get(whereClause = `status = ${"PLACED"}`);
        if placedOrders.length() == 0 {
            log:printInfo("No new orders to process.");
            return;
        }
        foreach PlacedOrdersType placedOrder in placedOrders {
            ordersdb:Order updatedOrder = check ordersDB->/orders/[placedOrder.orderId].put({status: "PROCESSING"});
            check emailSmtpclient->sendMessage({
                to: placedOrder.customer.email,
                subject: placedOrder.orderId + ": status update",
                body: "Your order bearing id :" + placedOrder.orderId + " is now under process"
            });
            log:printInfo(string `Order advanced to PROCESSING: ${updatedOrder.orderId}`);
        }
        log:printInfo(string `Done - processed ${placedOrders.length()} orders`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
