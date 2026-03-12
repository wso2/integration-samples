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

// Builds the Slack message by replacing placeholders with actual values
function buildSlackMessage(OrderDetails details, string template) returns string {
    string slackMessage = template;
    
    // Replace HTML line breaks with newlines
    slackMessage = re `<br>`.replaceAll(slackMessage, "\n");
    
    // Replace all placeholders
    slackMessage = re `\{orderId\}`.replaceAll(slackMessage, details.orderNumber);
    slackMessage = re `\{customerName\}`.replaceAll(slackMessage, details.customerFullName);
    slackMessage = re `\{customerEmail\}`.replaceAll(slackMessage, details.customerEmail);
    slackMessage = re `\{currency\}`.replaceAll(slackMessage, details.orderCurrency);
    slackMessage = re `\{totalPrice\}`.replaceAll(slackMessage, details.orderTotalPrice);
    slackMessage = re `\{itemCount\}`.replaceAll(slackMessage, details.itemCount.toString());
    slackMessage = re `\{items\}`.replaceAll(slackMessage, details.itemsDetails);
    slackMessage = re `\{subtotal\}`.replaceAll(slackMessage, details.orderSubtotal);
    slackMessage = re `\{taxes\}`.replaceAll(slackMessage, details.orderTaxes);
    slackMessage = re `\{shipping\}`.replaceAll(slackMessage, details.orderShipping);
    slackMessage = re `\{shippingAddress\}`.replaceAll(slackMessage, details.shippingAddress);
    slackMessage = re `\{financialStatus\}`.replaceAll(slackMessage, details.financialStatus);
    slackMessage = re `\{fulfillmentStatus\}`.replaceAll(slackMessage, details.fulfillmentStatus);
    slackMessage = re `\{createdAt\}`.replaceAll(slackMessage, details.createdAt);
    
    return slackMessage;
}
