import ballerinax/trigger.shopify;

// Extracts and formats order information from Shopify order event
function extractOrderDetails(shopify:OrderEvent event) returns OrderDetails {
    // Order ID
    int? eventId = event?.id;
    string orderNumber = eventId is int ? eventId.toString() : "Unknown";
    
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
function buildItemsList(shopify:OrderEvent event) returns string {
    string itemsDetails = "";
    
    if event?.line_items is shopify:LineItem[] {
        shopify:LineItem[] lineItems = event?.line_items ?: [];
        foreach shopify:LineItem item in lineItems {
            int? quantity = item?.quantity;
            string quantityStr = quantity is int ? quantity.toString() : "1";
            string productName = item?.name ?: "Unknown Product";
            itemsDetails = itemsDetails + "  • " + quantityStr + "x " + productName + "\n";
        }
    }
    
    return itemsDetails;
}

// Builds a formatted shipping address string
function buildShippingAddress(shopify:OrderEvent event) returns string {
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
function escapeHtml(string input) returns string {
    string escaped = input;
    escaped = re `&`.replaceAll(escaped, "&amp;");
    escaped = re `<`.replaceAll(escaped, "&lt;");
    escaped = re `>`.replaceAll(escaped, "&gt;");
    return escaped;
}

// Builds the Slack message by replacing placeholders with actual values
function buildSlackMessage(OrderDetails details, string template) returns string {
    string slackMessage = template;
    
    // Replace HTML line breaks with newlines
    slackMessage = re `<br>`.replaceAll(slackMessage, "\n");
    
    // Escape HTML special characters in user-provided fields
    string escapedCustomerName = escapeHtml(details.customerFullName);
    string escapedCustomerEmail = escapeHtml(details.customerEmail);
    string escapedItemsDetails = escapeHtml(details.itemsDetails);
    string escapedShippingAddress = escapeHtml(details.shippingAddress);
    string escapedOrderNumber = escapeHtml(details.orderNumber);
    string escapedCurrency = escapeHtml(details.orderCurrency);
    string escapedTotalPrice = escapeHtml(details.orderTotalPrice);
    string escapedSubtotal = escapeHtml(details.orderSubtotal);
    string escapedTaxes = escapeHtml(details.orderTaxes);
    string escapedShipping = escapeHtml(details.orderShipping);
    string escapedFinancialStatus = escapeHtml(details.financialStatus);
    string escapedFulfillmentStatus = escapeHtml(details.fulfillmentStatus);
    string escapedCreatedAt = escapeHtml(details.createdAt);
    
    // Replace all placeholders with escaped values
    slackMessage = re `\{orderId\}`.replaceAll(slackMessage, escapedOrderNumber);
    slackMessage = re `\{customerName\}`.replaceAll(slackMessage, escapedCustomerName);
    slackMessage = re `\{customerEmail\}`.replaceAll(slackMessage, escapedCustomerEmail);
    slackMessage = re `\{currency\}`.replaceAll(slackMessage, escapedCurrency);
    slackMessage = re `\{totalPrice\}`.replaceAll(slackMessage, escapedTotalPrice);
    slackMessage = re `\{itemCount\}`.replaceAll(slackMessage, details.itemCount.toString());
    slackMessage = re `\{items\}`.replaceAll(slackMessage, escapedItemsDetails);
    slackMessage = re `\{subtotal\}`.replaceAll(slackMessage, escapedSubtotal);
    slackMessage = re `\{taxes\}`.replaceAll(slackMessage, escapedTaxes);
    slackMessage = re `\{shipping\}`.replaceAll(slackMessage, escapedShipping);
    slackMessage = re `\{shippingAddress\}`.replaceAll(slackMessage, escapedShippingAddress);
    slackMessage = re `\{financialStatus\}`.replaceAll(slackMessage, escapedFinancialStatus);
    slackMessage = re `\{fulfillmentStatus\}`.replaceAll(slackMessage, escapedFulfillmentStatus);
    slackMessage = re `\{createdAt\}`.replaceAll(slackMessage, escapedCreatedAt);
    
    return slackMessage;
}
