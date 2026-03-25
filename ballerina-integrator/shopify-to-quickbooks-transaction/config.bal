// Shopify webhook authentication
configurable record {
    string apiSecretKey;
    // Order event that triggers the sync: FULFILLED, PAID, or COMPLETED
    "FULFILLED"|"PAID"|"COMPLETED" orderStatusTrigger = "PAID";
} shopifyConfig = ?;

// QuickBooks Online OAuth2 credentials and transaction behaviour
configurable record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string realmId;
    string serviceUrl;
    // Transaction type: INVOICE or SALES_RECEIPT
    "INVOICE"|"SALES_RECEIPT" transactionType = "INVOICE";
    // Auto-create QB customer if not found by email
    boolean createCustomerIfNotFound = true;
    // JSON string mapping Shopify SKUs to QB item IDs: {"sku-123": "qb-item-id-456"}
    string productMappingJson = "{}";
    // Whether to create a separate line item for shipping
    boolean mapShippingAsSeparateLine = true;
    // Name of the QB item to use for shipping lines (must match an item Name in QuickBooks)
    string shippingItemName = "Shipping";
    // Name of the QB item to use for discount lines (must match an item Name in QuickBooks)
    string discountItemName = "Discount";
    // Whether to create a negative line item for discounts
    boolean includeDiscountLineItems = true;
    // Whether to write the Shopify order ref into the QB transaction PrivateNote
    boolean addOrderReferenceToMemo = true;
    // Tax configuration
    record {
        string defaultTaxCode = "TAX";
        string taxMappingJson = "{}";
    } taxConfig = {defaultTaxCode: "TAX", taxMappingJson: "{}"};
    // Validation rules
    record {
        boolean requireCustomerEmail = true;
        boolean requireLineItems = true;
        decimal minimumOrderAmount = 0.0;
    } validationRules = {requireCustomerEmail: true, requireLineItems: true, minimumOrderAmount: 0.0};
} quickbooksConfig = ?;