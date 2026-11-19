import ballerina/ai;
import ballerina/time;
import ballerinax/shopify.admin;

final int returnWindowDays = 30;

# Looks up a customer order from Shopify by its order reference and resolves its delivery date
# from the order's fulfillment.
#
# + orderReference - the order reference to look up, e.g. "#1042"
# + return - the matching order with its delivered-days-ago value, or an error if no order was
# found or the order has not been fulfilled yet
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_shopify.admin_1.0.0.png"}
isolated function lookupOrder(string orderReference) returns Order|error {
    admin:OrdersList ordersList = check shopifyClient->retrieveAListOfOrders(name = orderReference, status = "any");
    admin:OrdersListOrders[]? orders = ordersList.orders;
    if orders is () || orders.length() == 0 {
        return error("No order found for reference " + orderReference);
    }
    admin:OrdersListOrders orderSummary = orders[0];
    int? orderId = orderSummary.id;
    if orderId is () {
        return error("Order " + orderReference + " has no id");
    }
    admin:SingleOrderResponse orderResponse = check shopifyClient->retrieveASpecificOrder(orderId.toString());
    admin:SingleOrderResponseOrder? 'order = orderResponse.'order;
    if 'order is () {
        return error("Order " + orderReference + " could not be retrieved");
    }
    admin:ReopenCloseOrderOrderFulfillments[]? fulfillments = 'order.fulfillments;
    if fulfillments is () || fulfillments.length() == 0 {
        return error("Order " + orderReference + " has not been fulfilled yet");
    }
    admin:ReopenCloseOrderOrderFulfillments fulfillment = fulfillments[0];
    admin:ReopenCloseOrderOrderLineItems[]? lineItems = fulfillment.lineItems;
    if lineItems is () || lineItems.length() == 0 {
        return error("Order " + orderReference + " has no line items");
    }
    admin:ReopenCloseOrderOrderLineItems lineItem = lineItems[0];
    int? variantId = lineItem["variantId"];
    if variantId is () {
        return error("Order " + orderReference + " line item has no variant");
    }
    string? fulfillmentCreatedAt = fulfillment.createdAt;
    if fulfillmentCreatedAt is () {
        return error("Order " + orderReference + " fulfillment has no delivery timestamp");
    }
    int deliveredDaysAgo = check daysSince(fulfillmentCreatedAt);
    string? lineItemTitle = lineItem.title;
    string? lineItemName = lineItem["name"];
    Order result = {
        orderReference: orderReference,
        itemName: lineItemTitle ?: (lineItemName ?: "Unknown item"),
        variantId: variantId,
        deliveredDaysAgo: deliveredDaysAgo
    };
    return result;
}

# Checks whether an order was delivered within the policy return window.
#
# + deliveredDaysAgo - number of days since the order was delivered
# + return - the eligibility result, or an error if the delivery age is negative
@ai:AgentTool
isolated function checkReturnWindowEligibility(int deliveredDaysAgo) returns EligibilityResult|error {
    if deliveredDaysAgo < 0 {
        return error("Delivery age must not be negative");
    }
    boolean withinWindow = deliveredDaysAgo <= returnWindowDays;
    EligibilityResult result = {
        withinReturnWindow: withinWindow,
        deliveredDaysAgo: deliveredDaysAgo,
        returnWindowDays: returnWindowDays
    };
    return result;
}

# Checks how many replacement units of a product variant are available in Shopify inventory.
#
# + variantId - the Shopify product variant id to check stock for
# + return - the number of replacement units available, or an error if the variant was not found
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_shopify.admin_1.0.0.png"}
isolated function checkReplacementStock(int variantId) returns int|error {
    admin:ProductVariantResponse variantResponse = check shopifyClient->receiveASingleProductVariant(variantId.toString());
    admin:ProductVariantResponseVariant? variant = variantResponse.variant;
    if variant is () {
        return error("No product variant found for id " + variantId.toString());
    }
    int? inventoryQuantity = variant.inventoryQuantity;
    if inventoryQuantity is () {
        return 0;
    }
    return inventoryQuantity;
}

# Retrieves the most relevant passages from the return policy document for a query.
#
# + query - the question or topic to search the return policy for
# + return - the matching policy passages, or an error if retrieval failed
@ai:AgentTool
isolated function retrieveReturnPolicy(string query) returns string|error {
    ai:QueryMatch[] matches = check returnPolicyKnowledgeBase.retrieve(query, 3);
    string[] excerpts = [];
    foreach ai:QueryMatch 'match in matches {
        excerpts.push('match.chunk.content.toString());
    }
    return string:'join("\n---\n", ...excerpts);
}

# Computes the number of whole days between a past timestamp and now.
#
# + pastTimestamp - an RFC 3339 timestamp, e.g. a Shopify fulfillment "created_at" value
# + return - the number of whole days that have elapsed since pastTimestamp, or an error if the
# timestamp could not be parsed
isolated function daysSince(string pastTimestamp) returns int|error {
    time:Utc pastUtc = check time:utcFromString(pastTimestamp);
    time:Utc nowUtc = time:utcNow();
    time:Seconds diffSeconds = time:utcDiffSeconds(nowUtc, pastUtc);
    return <int>(diffSeconds / 86400).floor();
}
