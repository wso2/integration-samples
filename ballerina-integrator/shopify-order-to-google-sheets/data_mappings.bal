import ballerinax/trigger.shopify;

# Helper function to extract discount codes
function getDiscountCodes(shopify:DiscountCode[]? codes) returns string {
    if codes is () || codes.length() == 0 {
        return "";
    }
    string[] codeList = from var code in codes select code?.code ?: "";
    return string:'join(", ", ...codeList);
}

# Helper function to extract shipping method
function getShippingMethod(shopify:ShippingLine[]? lines) returns string {
    if lines is () || lines.length() == 0 {
        return "";
    }
    return lines[0]?.title ?: "";
}

# Helper function to get shipping price
function getShippingPrice(shopify:ShippingLine[]? lines) returns string {
    if lines is () || lines.length() == 0 {
        return "0.00";
    }
    return lines[0]?.price ?: "0.00";
}

# Helper function to get customer ID
function getCustomerId(int? customerId) returns string {
    if customerId is () {
        return "";
    }
    return customerId.toString();
}

function eventToRowData(shopify:OrderEvent event) returns (int|string|decimal)[] => [
    // Order Identifiers
    event?.id.toString(),
    event?.order_number ?: "",
    formatDate(event?.created_at),
    formatDate(event?.updated_at),
    
    // Financial Summary
    event?.total_price ?: "0.00",
    event?.subtotal_price ?: "0.00",
    event?.total_tax ?: "0.00",
    event?.total_discounts ?: "0.00",
    getShippingPrice(event?.shipping_lines),
    event?.total_line_items_price ?: "0.00",
    event?.currency ?: "",
    
    // Payment Details
    event?.financial_status ?: "unknown",
    event?.gateway ?: "",
    getDiscountCodes(event?.discount_codes),
    
    // Order Status
    event?.fulfillment_status ?: "unfulfilled",
    formatDate(event?.processed_at),
    formatDate(event?.cancelled_at),
    
    // Customer Information
    getCustomerId(event?.customer?.id),
    event?.email ?: "",
    event?.customer?.first_name ?: "",
    event?.customer?.last_name ?: "",
    event?.customer?.phone ?: "",
    event?.phone ?: "",
    
    // Shipping Address
    event?.shipping_address?.first_name ?: "",
    event?.shipping_address?.last_name ?: "",
    event?.shipping_address?.address1 ?: "",
    event?.shipping_address?.address2 ?: "",
    event?.shipping_address?.city ?: "",
    event?.shipping_address?.province ?: "",
    event?.shipping_address?.zip ?: "",
    event?.shipping_address?.country ?: "",
    event?.shipping_address?.country_code ?: "",
    event?.shipping_address?.phone ?: "",
    getShippingMethod(event?.shipping_lines),
    
    // Billing Address
    event?.billing_address?.first_name ?: "",
    event?.billing_address?.last_name ?: "",
    event?.billing_address?.address1 ?: "",
    event?.billing_address?.city ?: "",
    event?.billing_address?.province ?: "",
    event?.billing_address?.zip ?: "",
    event?.billing_address?.country ?: "",
    
    // Order Metadata
    event?.source_name ?: "",
    event?.referring_site ?: "",
    event?.tags ?: "",
    event?.note ?: "",
    event?.total_weight ?: 0
];
