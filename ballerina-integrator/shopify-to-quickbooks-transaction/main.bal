import ballerina/log;
import ballerinax/trigger.shopify;

// ---------------------------------------------------------------------------
// Shopify Orders webhook service
// Handles orders/fulfilled and orders/paid events.
// All remote functions must be implemented (required by OrdersService interface).
// ---------------------------------------------------------------------------
service shopify:OrdersService on shopifyListener {

    remote function onOrdersFulfilled(shopify:OrderEvent event) returns error? {
        string|error num = orderNumStr(event);
        log:printInfo(string `[Shopify] orders/fulfilled received: #${num is string ? num : "unknown"}`);
        return processOrder(event);
    }

    remote function onOrdersPaid(shopify:OrderEvent event) returns error? {
        string|error num = orderNumStr(event);
        log:printInfo(string `[Shopify] orders/paid received: #${num is string ? num : "unknown"}`);
        return processOrder(event);
    }

    remote function onOrdersCreate(shopify:OrderEvent event) returns error? {
        return;
    }

    remote function onOrdersCancelled(shopify:OrderEvent event) returns error? {
        return;
    }

    remote function onOrdersPartiallyFulfilled(shopify:OrderEvent event) returns error? {
        return;
    }

    remote function onOrdersUpdated(shopify:OrderEvent event) returns error? {
        return;
    }
}
