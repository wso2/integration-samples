import ballerina/lang.regexp;
import ballerinax/trigger.shopify;

// Extracts and formats order information from Shopify order event
isolated function extractOrderDetails(shopify:OrderEvent event) returns OrderDetails {
    // Order ID
    int? eventId = event?.id;
    boolean hasRealOrderId = eventId is int;
    string orderNumber = hasRealOrderId ? eventId.toString() : "Unknown";
    
    // Customer information
    string customerFirstName = event?.customer?.first_name ?: "Unknown";
    string customerLastName = event?.customer?.last_name ?: "";
    string customerFullName = customerLastName != "" ? customerFirstName + " " + customerLastName : customerFirstName;
    string customerEmail = event?.customer?.email ?: "N/A";
    
    // Order financial details
    string orderTotalPrice = event?.total_price ?: "0.00";
    string orderCurrency = event?.currency ?: "USD";
    string orderSubtotal = event?.subtotal_price ?: "0.00";
    string orderTaxes = event?.total_tax ?: "0.00";
    string orderShipping = event?.total_shipping_price_set?.shop_money?.amount ?: "0.00";
    
    // Order items
    int itemCount = event?.line_items is () ? 0 : (event?.line_items ?: []).length();
    string itemsDetails = buildItemsList(event);
    
    // Shipping address
    string shippingAddress = buildShippingAddress(event);
    
    // Order status
    string financialStatus = event?.financial_status ?: "pending";
    string fulfillmentStatus = event?.fulfillment_status ?: "unfulfilled";
    
    // Order creation date
    string createdAt = event?.created_at ?: "N/A";
    
    return {
        orderNumber,
        hasRealOrderId,
        customerFullName,
        customerEmail,
        orderTotalPrice,
        orderCurrency,
        orderSubtotal,
        orderTaxes,
        orderShipping,
        itemCount,
        itemsDetails,
        shippingAddress,
        financialStatus,
        fulfillmentStatus,
        createdAt
    };
}

// Builds a formatted list of order items
isolated function buildItemsList(shopify:OrderEvent event) returns string {
    shopify:LineItem[] lineItems = event?.line_items ?: [];
    
    string[] itemLines = from shopify:LineItem item in lineItems
                         let int? quantity = item?.quantity
                         let string quantityStr = quantity is int ? quantity.toString() : "1"
                         let string productName = item?.name ?: "Unknown Product"
                         select "  • " + quantityStr + "x " + productName;
    
    return string:'join("\n", ...itemLines) + (itemLines.length() > 0 ? "\n" : "");
}

// Builds a formatted shipping address string
isolated function buildShippingAddress(shopify:OrderEvent event) returns string {
    string shippingCity = event?.shipping_address?.city ?: "";
    string shippingCountry = event?.shipping_address?.country ?: "";
    
    if shippingCity != "" && shippingCountry != "" {
        return shippingCity + ", " + shippingCountry;
    } else if shippingCity != "" {
        return shippingCity;
    } else if shippingCountry != "" {
        return shippingCountry;
    } else {
        return "N/A";
    }
}

// Escapes HTML special characters to prevent Slack mrkdwn interpretation
isolated function escapeSlackText(string input) returns string {
    string escaped = input;
    escaped = re `&`.replaceAll(escaped, "&amp;");
    escaped = re `<`.replaceAll(escaped, "&lt;");
    escaped = re `>`.replaceAll(escaped, "&gt;");
    return escaped;
}

// Builds the Slack message by replacing placeholders with actual values
isolated function buildSlackMessage(OrderDetails details, string template) returns string|error {
    string slackMessage = template;
    
    // Replace HTML line breaks with newlines
    string:RegExp brPattern = re `<br>`;
    slackMessage = brPattern.replaceAll(slackMessage, "\n");
    
    // Map placeholders to their escaped values
    map<string> placeholders = {
        "orderId": escapeSlackText(details.orderNumber),
        "customerName": escapeSlackText(details.customerFullName),
        "customerEmail": escapeSlackText(details.customerEmail),
        "currency": escapeSlackText(details.orderCurrency),
        "totalPrice": escapeSlackText(details.orderTotalPrice),
        "itemCount": details.itemCount.toString(),
        "items": escapeSlackText(details.itemsDetails),
        "subtotal": escapeSlackText(details.orderSubtotal),
        "taxes": escapeSlackText(details.orderTaxes),
        "shipping": escapeSlackText(details.orderShipping),
        "shippingAddress": escapeSlackText(details.shippingAddress),
        "financialStatus": escapeSlackText(details.financialStatus),
        "fulfillmentStatus": escapeSlackText(details.fulfillmentStatus),
        "createdAt": escapeSlackText(details.createdAt)
    };
    
    // Replace all placeholders with their values
    foreach [string, string] [placeholder, value] in placeholders.entries() {
        string:RegExp pattern = check regexp:fromString("\\{" + placeholder + "\\}");
        slackMessage = pattern.replaceAll(slackMessage, value);
    }
    
    return slackMessage;
}
