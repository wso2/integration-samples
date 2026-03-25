import ballerina/log;
import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// Helper to safely convert int? order_number to string.
// Returns an error if neither order_number nor id is present so callers can quarantine the event.
function orderNumStr(shopify:OrderEvent event) returns string|error {
    int? num = event?.order_number;
    if num is int {
        return num.toString();
    }
    int? id = event?.id;
    if id is int {
        return id.toString();
    }
    return error("Order event has no identifiable order_number or id");
}

// In-memory idempotency barrier: tracks order IDs currently in-flight (false) or successfully created in QB (true).
// Prevents concurrent duplicate creation when onOrdersFulfilled and onOrdersPaid both fire for the same order.
final map<boolean> processedOrderIds = {};

// Safely extracts the QB-assigned Id from a toJson() response for the given entity type.
// Returns "unknown" if the entity or Id field is absent.
function extractQBId(json response, string entityName) returns string {
    if response is map<json> {
        json? entity = response[entityName];
        if entity is map<json> {
            json? id = entity["Id"];
            if id !is () {
                return id.toString();
            }
        }
    }
    return "unknown";
}

// ---------------------------------------------------------------------------
// Shopify Orders webhook service
// Handles orders/fulfilled and orders/paid events.
// All remote functions must be implemented (required by OrdersService interface).
// ---------------------------------------------------------------------------
service shopify:OrdersService on shopifyListener {

    remote function onOrdersFulfilled(shopify:OrderEvent event) returns error? {
        string|error num = orderNumStr(event);
        log:printInfo(string `[Shopify] orders/fulfilled received: #${num is string ? num : "unknown"}`);
        return processOrder(event);
    }

    remote function onOrdersPaid(shopify:OrderEvent event) returns error? {
        string|error num = orderNumStr(event);
        log:printInfo(string `[Shopify] orders/paid received: #${num is string ? num : "unknown"}`);
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
    // Fail fast if the event carries no usable order identifier
    string|error orderNumResult = orderNumStr(event);
    if orderNumResult is error {
        quarantineOrder(event, "Order has no identifiable order number or ID", "VALIDATION");
        return;
    }
    string orderNum = orderNumResult;
    // Use the validated order number as the idempotency key to avoid collisions on a default ID.
    string orderId = orderNum;

    // Atomic check-and-set: if another event for the same order is already in-flight or done, skip
    boolean alreadyTracked;
    lock {
        alreadyTracked = processedOrderIds.hasKey(orderId);
        if !alreadyTracked {
            processedOrderIds[orderId] = false; // false = in-flight
        }
    }
    if alreadyTracked {
        log:printInfo(string `[Skip] Order #${orderNum} (ID: ${orderId}): already being processed or completed`);
        return;
    }

    do {
        // 1. Status filter (FULFILLED / PAID / COMPLETED)
        if !shouldProcessOrder(event) {
            log:printInfo(string `[Skip] Order #${orderNum}: status does not match trigger '${shopifyConfig.orderStatusTrigger}'`);
            lock { _ = processedOrderIds.removeIfHasKey(orderId); }
            return;
        }

        // 2. Minimum amount validation
        string? totalStr = event?.total_price;
        if totalStr is () {
            if quickbooksConfig.validationRules.minimumOrderAmount > 0d {
                log:printWarn(string `[Skip] Order #${orderNum}: total_price is null and minimumOrderAmount is ${quickbooksConfig.validationRules.minimumOrderAmount}; rejecting order.`);
                lock { _ = processedOrderIds.removeIfHasKey(orderId); }
                return;
            }
        } else {
            decimal total = check decimal:fromString(totalStr);
            if total < quickbooksConfig.validationRules.minimumOrderAmount {
                log:printInfo(string `[Skip] Order #${orderNum}: total ${total} below minimum ${quickbooksConfig.validationRules.minimumOrderAmount}`);
                lock { _ = processedOrderIds.removeIfHasKey(orderId); }
                return;
            }
        }

        // 3. Required fields validation
        shopify:OrderLineItem[]? lineItems = event?.line_items;
        if quickbooksConfig.validationRules.requireLineItems && (lineItems is () || lineItems.length() == 0) {
            quarantineOrder(event, "Order has no line items", "VALIDATION");
            lock { _ = processedOrderIds.removeIfHasKey(orderId); }
            return;
        }

        // 4. Duplicate prevention — check if already synced to QB
        boolean duplicate = check isDuplicateTransaction(orderNum);
        if duplicate {
            log:printInfo(string `[Skip] Order #${orderNum}: already synced to QuickBooks (duplicate)`);
            lock { processedOrderIds[orderId] = true; }
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

        string idStr = extractQBId(qbResult.toJson(), "Invoice");

        string docType = quickbooksConfig.transactionType == "INVOICE" ? "Invoice" : "Sales Receipt (as Invoice)";

        lock { processedOrderIds[orderId] = true; }
        log:printInfo(string `[QB] ${docType} created: Id=${idStr} for Order #${orderNum}`);

    } on fail error e {
        lock { _ = processedOrderIds.removeIfHasKey(orderId); }
        log:printError(string `[Error] Failed to process Order #${orderNum}: ${e.message()}`, 'error = e);
        quarantineOrder(event, e.message(), "UNKNOWN_ERROR");
        return e;
    }
}
