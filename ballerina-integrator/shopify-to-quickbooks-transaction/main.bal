import ballerina/log;
import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// Helper to safely convert int? order_number to string
function orderNumStr(shopify:OrderEvent event) returns string {
    int? num = event?.order_number;
    if num is int {
        return num.toString();
    }
    int? id = event?.id;
    return id is int ? id.toString() : "unknown";
}

// ---------------------------------------------------------------------------
// Shopify Orders webhook service
// Handles orders/fulfilled and orders/paid events.
// All remote functions must be implemented (required by OrdersService interface).
// ---------------------------------------------------------------------------
service shopify:OrdersService on shopifyListener {

    remote function onOrdersFulfilled(shopify:OrderEvent event) returns error? {
        log:printInfo(string `[Shopify] orders/fulfilled received: #${orderNumStr(event)}`);
        return processOrder(event);
    }

    remote function onOrdersPaid(shopify:OrderEvent event) returns error? {
        log:printInfo(string `[Shopify] orders/paid received: #${orderNumStr(event)}`);
        return processOrder(event);
    }

    remote function onOrdersCreate(shopify:OrderEvent event) returns error? {
        return;
    }

    remote function onOrdersCancelled(shopify:OrderEvent event) returns error? {
        return;
    }

    remote function onOrdersPartiallyFulfilled(shopify:OrderEvent event) returns error? {
        return;
    }

    remote function onOrdersUpdated(shopify:OrderEvent event) returns error? {
        return;
    }
}

// ---------------------------------------------------------------------------
// Core order processing pipeline
// ---------------------------------------------------------------------------
function processOrder(shopify:OrderEvent event) returns error? {
    string orderNum = orderNumStr(event);

    do {
        // 1. Status filter (FULFILLED / PAID / COMPLETED)
        if !shouldProcessOrder(event) {
            log:printInfo(string `[Skip] Order #${orderNum}: status does not match trigger '${orderStatusTrigger}'`);
            return;
        }

        // 2. Minimum amount validation
        string? totalStr = event?.total_price;
        if totalStr is () {
            if validationRules.minimumOrderAmount > 0d {
                log:printWarn(string `[Skip] Order #${orderNum}: total_price is null and minimumOrderAmount is ${validationRules.minimumOrderAmount}; rejecting order.`);
                return;
            }
        } else {
            decimal total = check decimal:fromString(totalStr);
            if total < validationRules.minimumOrderAmount {
                log:printInfo(string `[Skip] Order #${orderNum}: total ${total} below minimum ${validationRules.minimumOrderAmount}`);
                return;
            }
        }


        // 3. Required fields validation
        shopify:OrderLineItem[]? lineItems = event?.line_items;
        if validationRules.requireLineItems && (lineItems is () || lineItems.length() == 0) {
            quarantineOrder(event, "Order has no line items", "VALIDATION");
            return;
        }

        // 4. Duplicate prevention — check if already synced to QB
        boolean duplicate = check isDuplicateTransaction(orderNum);
        if duplicate {
            log:printInfo(string `[Skip] Order #${orderNum}: already synced to QuickBooks (duplicate)`);
            return;
        }

        // 5. Get or create QuickBooks customer
        // billing_address is shopify:CustomerAddress? on OrderEvent
        string customerId = check getOrCreateQBCustomer(event?.customer, event?.billing_address);

        // 6. Build and create QuickBooks Invoice
        // Note: ballerinax/quickbooks.online v1.5.1 provides createOrUpdateInvoice (no SalesReceipt method)
        // 'transaction' is a reserved keyword in Ballerina — variable named qbInvoice
        quickbooks:InvoiceCreateObject qbInvoice = check mapToQBTransaction(event, customerId);
        quickbooks:InvoiceResponse qbResult = check quickbooksClient->createOrUpdateInvoice(
            quickbooksConfig.realmId, qbInvoice);

        json qbJson = qbResult.toJson();
        json|error invoiceObj = qbJson.Invoice;
        json|error qbId = ();
        if invoiceObj is json {
            qbId = invoiceObj.Id;
        }
        string idStr = qbId is json ? qbId.toString() : "unknown";
        string docType = transactionType == "INVOICE" ? "Invoice" : "Sales Receipt (as Invoice)";
        log:printInfo(string `[QB] ${docType} created: Id=${idStr} for Order #${orderNum}`);

    } on fail error e {
        log:printError(string `[Error] Failed to process Order #${orderNum}: ${e.message()}`, 'error = e);
        quarantineOrder(event, e.message(), "UNKNOWN_ERROR");
        return e;
    }
}
