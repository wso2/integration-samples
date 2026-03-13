import ballerina/log;
import ballerinax/trigger.shopify;

// Shopify webhook service to handle order events
service shopify:OrdersService on shopifyListener {
    // Triggered when a new order is created in Shopify
    remote function onOrdersCreate(shopify:OrderEvent event) returns error? {
        log:printInfo("Received Shopify order creation request");

        // Extract order details from the event
        OrderDetails orderDetails = extractOrderDetails(event);

        // Check if order price meets the minimum threshold
        decimal orderPrice = check decimal:fromString(orderDetails.orderTotalPrice);
        decimal minPrice = <decimal>minimumOrderPrice;
        if orderPrice < minPrice {
            log:printInfo(string `Order price ${orderPrice} is below minimum threshold ${minPrice}. Skipping notification.`);
            return;
        }

        // Build the Slack message using the custom template
        string slackMessage = buildSlackMessage(orderDetails, customMessage);

        // Post the message to Slack with deduplication via client_msg_id
        _ = check slackClient->/chat\.postMessage.post(
            payload = {
                channel: slackChannelId,
                text: slackMessage,
                "client_msg_id": orderDetails.orderNumber
            }
        );

        log:printInfo(string `Successfully posted order ${orderDetails.orderNumber} to Slack`);
    }

    remote function onOrdersCancelled(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersFulfilled(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersPaid(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersPartiallyFulfilled(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersUpdated(shopify:OrderEvent event) returns error? {
    }
}
