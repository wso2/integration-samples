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
