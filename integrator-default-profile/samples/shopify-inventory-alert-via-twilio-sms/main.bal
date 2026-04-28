import ballerinax/trigger.shopify;
import ballerina/log;

// Track per-variant and per-recipient cooldowns to avoid duplicate alerts within the cooldown window.
// NOTE: This map is process-local (in-memory only). State is lost on restart.
isolated map<AlertCooldown> cooldownTracker = {};

function init() {
    log:printInfo("Shopify inventory alert service started. Listening for Shopify order events",
        port = 8090,
        inventoryThreshold = inventoryThreshold,
        cooldownPeriodHours = cooldownPeriodHours);
}

service shopify:OrdersService on shopifyListener {

    remote function onOrdersCreate(shopify:OrderEvent event) returns error? {
        int orderId = event?.id ?: 0;
        log:printInfo("Trigger fired: new Shopify order received", orderId = orderId);

        shopify:LineItem[]? lineItems = event?.line_items;
        if lineItems is () || lineItems.length() == 0 {
            log:printInfo("No line items found in order", orderId = orderId);
            return;
        }

        check processOrderedLineItems(lineItems);
    }

    remote function onOrdersUpdated(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersCancelled(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersFulfilled(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersPaid(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersPartiallyFulfilled(shopify:OrderEvent event) returns error? {
    }
}
