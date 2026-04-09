import ballerina/log;
import ballerina/uuid;
import ballerinax/trigger.shopify;

// Shopify webhook service to handle order events
service shopify:OrdersService on shopifyListener {
    // Triggered when a new order is created in Shopify
    remote function onOrdersCreate(shopify:OrderEvent event) returns error? {
        log:printInfo("onOrdersCreate: Received Shopify order creation request");

        // Extract order details from the event
        OrderDetails orderDetails = extractOrderDetails(event);

        // Check if order price meets the minimum threshold
        decimal orderPrice = check decimal:fromString(orderDetails.orderTotalPrice);
        if orderPrice < minimumOrderPrice {
            log:printInfo(string `onOrdersCreate: Order price ${orderPrice} is below minimum threshold ${minimumOrderPrice}. Skipping notification.`);
            return;
        }

        // Build the Slack message using the custom template
        string slackMessage = check buildSlackMessage(orderDetails, customMessage);

        // Determine client_msg_id for deduplication
        string clientMsgId = orderDetails.hasRealOrderId ? orderDetails.orderNumber : uuid:createType1AsString();

        // Post the message to Slack
        _ = check slackClient->/chat\.postMessage.post(
            payload = {
                channel: slackConfig.channel,
                text: slackMessage,
                "client_msg_id": clientMsgId
            }
        );

        log:printInfo(string `onOrdersCreate: Successfully posted order ${orderDetails.orderNumber} to Slack`);
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
