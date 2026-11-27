import ballerina/ai;
import ballerina/dataservice;
import ballerina/time;
import ballerinax/shopify.admin;

# Finds Shopify orders by order name, such as #1042.
# + name - the order name, such as #1042
# + status - the order status filter; use any to include closed orders
# + return - Type of the variable
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_shopify.admin_3.0.0.png"}
isolated function findOrder(string name, string status) returns admin:OrdersList|error {
    admin:OrdersList adminOrderslist = check shopifyClient->retrieveAListOfOrders(name = name, status = status);
    return adminOrderslist;
}

# Gets one order by its id, with its fulfillments, ship dates and shipped items.
# + orderId - The ID of the order
# + return - Type of the variable
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_shopify.admin_3.0.0.png"}
isolated function getOrderDetails(string orderId) returns admin:SingleOrderResponse|error {
    admin:SingleOrderResponse adminSingleorderresponse = check shopifyClient->retrieveASpecificOrder(orderId);
    return adminSingleorderresponse;
}

# Gets a product variant by its id, including its inventory quantity.
# + variantId - The ID of the product variant
# + return - Type of the variable
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_shopify.admin_3.0.0.png"}
isolated function checkReplacementStock(string variantId) returns admin:ProductVariantResponse|error {
    admin:ProductVariantResponse adminProductvariantresponse = check shopifyClient->receiveASingleProductVariant(variantId);
    return adminProductvariantresponse;
}

# Gets the current date and time.
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerina_time_2.8.4.png"}
isolated function getCurrentTime() returns time:Utc {
    time:Utc result = time:utcNow();
    return result;
}

# Converts an ISO 8601 timestamp, such as a ship date, to UTC time.
# + value - The date-time; an offset other than `Z` is converted to UTC
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerina_dataservice_0.1.0.png"}
isolated function parseShipDate(string value) returns time:Utc|error {
    time:Utc result = check dataservice:utcFromString(value);
    return result;
}

# Returns the seconds from the second UTC time to the first.
# + utc1 - 1st UTC time as a tuple `[int, decimal]`, where the first element is the seconds from the epoch
# and the second element is the fractional part of the last second.
# + utc2 - 2nd UTC time as a tuple `[int, decimal]`, where the first element is the seconds from the epoch
# and the second element is the fractional part of the last second.
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerina_time_2.8.4.png"}
isolated function secondsBetween(time:Utc utc1, time:Utc utc2) returns time:Seconds {
    time:Seconds result = time:utcDiffSeconds(utc1, utc2);
    return result;
}

final ai:Agent customerReturnsAgent = check new (
    systemPrompt = {
        role: string `Customer Returns Assistant`,
        instructions: string `You help customers with return and exchange requests for faulty or defective items. You recommend one of three resolutions: an exchange, a refund, or manual review, and you explain the reason with a reference to the return policy below. You never create a return, process a refund, or move money yourself - you only recommend what should happen.

Return policy:
- A customer may request a resolution within 30 days of the date the item was shipped. Later requests go to manual review.
- Exchange: the item is faulty or defective, it shipped within the last 30 days, and a replacement is in stock.
- Refund: the item is faulty or defective, it shipped within the last 30 days, and no replacement is in stock.
- Manual review: the item shipped more than 30 days ago, the order or item cannot be found, the fault is unclear or disputed, the request is a change-of-mind return, or anything else that does not clearly match the exchange or refund rules.

Follow this process for every request:
1. If the customer has not given an order reference, such as #1042, ask for it before doing anything else.
2. Call findOrder with the order reference as the order name and with status any, and take the id of the matching order. If no order matches, recommend manual review.
3. Call getOrderDetails with that order id. Use only fulfillments whose status is success. Each one lists the shipped items with their variant ids, and its creation date is the date those items shipped.
4. Identify the item the customer is reporting. If several items shipped and the message does not clearly name one of them, list the item names and ask which one is faulty before going further.
5. Call getCurrentTime, call parseShipDate with the item's ship date, and then call secondsBetween with the current time first and the ship time second. The item shipped within the last 30 days when the result is at most 2592000 seconds; divide it by 86400 to get the whole days since that item shipped.
6. If the item shipped within the last 30 days, has a variant id, and is faulty or defective, call checkReplacementStock with its variant id. Recommend an exchange when its inventory quantity is above zero, and a refund otherwise.
7. In every other case, recommend manual review.
8. Always state your final recommendation clearly (exchange, refund, or manual review), explain the reason, and quote the policy rule that supports it.`
    }, model = check ai:getDefaultModelProvider(), tools = [findOrder, getOrderDetails, checkReplacementStock, getCurrentTime, parseShipDate, secondsBetween]
);
