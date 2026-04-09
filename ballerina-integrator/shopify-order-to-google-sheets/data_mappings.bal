import ballerinax/trigger.shopify;
import ballerina/time;

# Formats a date string according to the configured date format
# + dateString - The input date string (RFC 3339 format from Shopify)
# + return - Formatted date string or original if formatting fails/not configured
isolated function formatDate(string? dateString) returns string {
    if dateString is () {
        return "";
    }

    time:Civil|time:Error civilResult = time:civilFromString(dateString);
    if civilResult is time:Error {
        return dateString;
    }

    match dateFormat {
        "iso8601" => {
            string|time:Error formatted = time:civilToString(civilResult);
            if formatted is string {
                return formatted;
            }
        }
        "rfc5322" => {
            string|time:Error formatted = time:civilToEmailString(civilResult, time:PREFER_ZONE_OFFSET);
            if formatted is string {
                return formatted;
            }
        }
    }
    return dateString;
}

# Helper function to extract discount codes
# + codes - Array of discount code objects from Shopify order
# + return - Comma-separated string of discount codes or empty string if none
isolated function getDiscountCodes(shopify:DiscountCode[]? codes) returns string {
    if codes is () || codes.length() == 0 {
        return "";
    }
    string[] codeList = from var code in codes let string c = code?.code ?: "" where c != "" select c;

    return string:'join(", ", ...codeList);
}

# Helper function to retrieve the first shipping line
# + lines - Array of shipping line objects from Shopify order
# + return - The first ShippingLine record, or nil if not available
isolated function getFirstShippingLine(shopify:ShippingLine[]? lines) returns shopify:ShippingLine? {
    if lines is () || lines.length() == 0 {
        return ();
    }
    return lines[0];
}

isolated function eventToRowData(shopify:OrderEvent event) returns (int|string|decimal)[] => [
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
    getFirstShippingLine(event?.shipping_lines)?.price ?: "0.00",
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
    event?.customer?.id ?: "",
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
    getFirstShippingLine(event?.shipping_lines)?.title ?: "",
    
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
