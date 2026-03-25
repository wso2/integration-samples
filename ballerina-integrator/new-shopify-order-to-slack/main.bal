import ballerina/log;
import ballerina/uuid;
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
        if orderPrice < minimumOrderPrice {
            log:printInfo(string `Order price ${orderPrice} is below minimum threshold ${minimumOrderPrice}. Skipping notification.`);
            return;
        }

        // Build the Slack message using the custom template
        string slackMessage = buildSlackMessage(orderDetails, customMessage);

        // Post the message to Slack with deduplication via client_msg_id (only if we have a real order ID)
        if orderDetails.hasRealOrderId {
            _ = check slackClient->/chat\.postMessage.post(
                payload = {
                    channel: slackConfig.channelId,
                    text: slackMessage,
                    "client_msg_id": orderDetails.orderNumber
                }
            );
        } else {
            // Generate a unique ID for orders without a real ID to prevent deduplication issues
            string uniqueId = uuid:createType1AsString();
            _ = check slackClient->/chat\.postMessage.post(
                payload = {
                    channel: slackConfig.channelId,
                    text: slackMessage,
                    "client_msg_id": uniqueId
                }
            );
        }

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
