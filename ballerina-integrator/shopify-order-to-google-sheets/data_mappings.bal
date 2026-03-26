import ballerinax/trigger.shopify;
import ballerina/time;

# Formats a date string according to the configured date format
# + dateString - The input date string (RFC 3339 format from Shopify)
# + return - Formatted date string or original if formatting fails/not configured
function formatDate(string? dateString) returns string {
    if dateString is () {
        return "";
    }
    if dateFormat == "default" || dateString.trim() == "" {
        return dateString;
    }

    time:Civil|time:Error civilResult = time:civilFromString(dateString);
    if civilResult is time:Error {
        return dateString;
    }

    time:Civil civil = civilResult;

    if dateFormat == "iso8601" {
        string|time:Error formatted = time:civilToString(civil);
        if formatted is string {
            return formatted;
        }
    } else if dateFormat == "rfc5322" {
        string|time:Error formatted = time:civilToEmailString(civil, time:PREFER_ZONE_OFFSET);
        if formatted is string {
            return formatted;
        }
    }

    return dateString;
}

# Helper function to extract discount codes
# + codes - Array of discount code objects from Shopify order
# + return - Comma-separated string of discount codes or empty string if none
function getDiscountCodes(shopify:DiscountCode[]? codes) returns string {
    if codes is () || codes.length() == 0 {
        return "";
    }
    string[] codeList = from var code in codes select code?.code ?: "";
    return string:'join(", ", ...codeList);
}

# Helper function to extract shipping method
# + lines - Array of shipping line objects from Shopify order
# + return - Shipping method title or empty string if not available
function getShippingMethod(shopify:ShippingLine[]? lines) returns string {
    if lines is () || lines.length() == 0 {
        return "";
    }
    return lines[0]?.title ?: "";
}

# Helper function to get shipping price
# + lines - Array of shipping line objects from Shopify order
# + return - Shipping price as string or "0.00" if not available
function getShippingPrice(shopify:ShippingLine[]? lines) returns string {
    if lines is () || lines.length() == 0 {
        return "0.00";
    }
    return lines[0]?.price ?: "0.00";
}

# Helper function to get customer ID
# + customerId - Customer ID from Shopify order (nullable)
# + return - Customer ID as string or empty string if not available
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
