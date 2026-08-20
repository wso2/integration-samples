// --- Vendor config types ---

type ShopifyConfig record {
    string apiSecretKey;
    "FULFILLED"|"PAID"|"COMPLETED" orderStatusTrigger = "PAID";
};

type TaxConfig record {
    string defaultTaxCode = "TAX";
    string taxMappingJson = "{}";
};

type ValidationRules record {
    boolean requireCustomerEmail = true;
    boolean requireLineItems = true;
    decimal minimumOrderAmount = 0.0;
};

type QuickBooksConfig record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string realmId;
    string serviceUrl;
    "INVOICE"|"SALES_RECEIPT" transactionType = "INVOICE";
    int invoiceDueDays = 30;
    boolean createCustomerIfNotFound = true;
    string productMappingJson = "{}";
    boolean mapShippingAsSeparateLine = true;
    string shippingItemName = "Shipping";
    string discountItemName = "Discount";
    boolean includeDiscountLineItems = true;
    boolean addOrderReferenceToMemo = true;
    TaxConfig taxConfig = {};
    ValidationRules validationRules = {};
};

// Record for logging/quarantining orders that cannot be processed
type QuarantinedOrder record {
    string orderId;
    string orderNumber;
    string quarantineReason;
    string errorType;
    string timestamp;
    boolean retryEligible;
};

// Helper record for building a QuickBooks SalesItemLineDetail as json
// (QB connector accepts anydata[] for Line — we build these as json maps)
type QBSalesItemLineDetail record {
    record {string value;} ItemRef;
    decimal UnitPrice?;
    decimal Qty?;
    record {string value;} TaxCodeRef?;
};

// A single QuickBooks sales line item (used as anydata in SalesReceipt/Invoice)
type QBSalesLine record {
    string DetailType;
    decimal Amount;
    string Description?;
    QBSalesItemLineDetail SalesItemLineDetail?;
};
