// Shopify webhook authentication
configurable record {
    string apiSecretKey;
} shopifyConfig = ?;

// QuickBooks Online OAuth2 credentials
configurable record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string realmId;
    string serviceUrl;
} quickbooksConfig = ?;

// Transaction type: SALES_RECEIPT or INVOICE
configurable string transactionType = "INVOICE";

// Order event that triggers the sync: FULFILLED, PAID, or COMPLETED
configurable string orderStatusTrigger = "PAID";

// Auto-create QB customer if not found by email
configurable boolean createCustomerIfNotFound = true;

// JSON string mapping Shopify SKUs to QB item IDs: {"sku-123": "qb-item-id-456"}
configurable string productMappingJson = "{}";

// Tax configuration
configurable record {
    string defaultTaxCode;
    string taxMappingJson;
} taxConfig = {
    defaultTaxCode: "TAX",
    taxMappingJson: "{}"
};

// Whether to create a separate line item for shipping
configurable boolean mapShippingAsSeparateLine = true;

// Name of the QB item to use for shipping lines (must match an item Name in QuickBooks)
configurable string shippingItemName = "Shipping";

// Name of the QB item to use for discount lines (must match an item Name in QuickBooks)
configurable string discountItemName = "Discount";

// Whether to create a negative line item for discounts
configurable boolean includeDiscountLineItems = true;

// Whether to write the Shopify order ref into the QB transaction PrivateNote
configurable boolean addOrderReferenceToMemo = true;

// Validation rules
configurable record {
    boolean requireCustomerEmail;
    boolean requireLineItems;
    decimal minimumOrderAmount;
} validationRules = {
    requireCustomerEmail: true,
    requireLineItems: true,
    minimumOrderAmount: 0.0
};

// Fail fast at module startup if enum-like config values are unrecognized.
function init() returns error? {
    if transactionType != "INVOICE" && transactionType != "SALES_RECEIPT" {
        return error(string `Invalid transactionType: '${transactionType}'. Expected INVOICE or SALES_RECEIPT.`);
    }
    if orderStatusTrigger != "FULFILLED" && orderStatusTrigger != "PAID" && orderStatusTrigger != "COMPLETED" {
        return error(string `Invalid orderStatusTrigger: '${orderStatusTrigger}'. Expected FULFILLED, PAID, or COMPLETED.`);
    }
}
