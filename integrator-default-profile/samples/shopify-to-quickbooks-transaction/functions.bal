import ballerina/constraint;
import ballerina/log;
import ballerina/time;
import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// --- Parsed product SKU → QB item ID map (loaded once at module init) ---
final map<string> & readonly productMap = check loadProductMap();

function loadProductMap() returns map<string> & readonly|error {
    log:printInfo("[Config] productMappingJson = " + quickbooksConfig.productMappingJson);
    json parsed = check (quickbooksConfig.productMappingJson).fromJsonString();
    map<string> m = {};
    if parsed is map<json> {
        foreach var [k, v] in parsed.entries() {
            m[k] = v.toString();
        }
        log:printInfo("[Config] productMap loaded with " + m.length().toString() + " entries: " + m.toString());
        return m.cloneReadOnly();
    }
    return error("[Config] Invalid productMappingJson: expected a JSON object mapping product SKUs to QuickBooks item IDs");
}

// --- Order status filter ---
function shouldProcessOrder(shopify:OrderEvent event) returns boolean {
    match shopifyConfig.orderStatusTrigger {
        "FULFILLED" => {
            return (event?.fulfillment_status ?: "") == "fulfilled";
        }
        "PAID" => {
            return (event?.financial_status ?: "") == "paid";
        }
        "COMPLETED" => {
            return (event?.fulfillment_status ?: "") == "fulfilled"
                && (event?.financial_status ?: "") == "paid";
        }
        _ => {
            return false;
        }
    }
}

// --- Duplicate check: query QB for an existing Invoice with this order number in PrivateNote ---
// orderNum is always produced by int.toString() in orderNumStr(), so it is guaranteed to be
// a non-empty string of decimal digits — no further format validation is needed here.
function isDuplicateTransaction(string orderNum) returns boolean|error {
    string query = string `SELECT Id FROM Invoice WHERE PrivateNote LIKE '%Shopify Order: ${orderNum} | ID:%'`;
    json|error result = quickbooksClient->queryEntity(quickbooksConfig.realmId, query);
    if result is map<json> {
        json? queryResponse = result["QueryResponse"];
        if queryResponse is map<json> {
            json? invoices = queryResponse["Invoice"];
            if invoices is json[] {
                return invoices.length() > 0;
            }
        }
    }
    return false;
}

// Constrained type used to validate that an email is non-empty and matches a standard pattern.
@constraint:String {
    pattern: {
        value: re `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`,
        message: "Invalid email address format"
    }
}
type Email string;

// --- Customer lookup / auto-creation ---
// OrderEvent.customer is shopify:Customer? and OrderEvent.billing_address is shopify:CustomerAddress?
function getOrCreateQBCustomer(shopify:Customer? customer, shopify:CustomerAddress? billingAddr) returns string|error {
    string? rawEmail = customer?.email;
    if rawEmail is () || rawEmail == "" {
        if quickbooksConfig.validationRules.requireCustomerEmail {
            return error("Customer email is required but missing");
        }
        return error("Customer email is missing and no default QuickBooks customer is configured");
    }

    // Validate the email format using ballerina/constraint
    Email emailValue = rawEmail;
    Email|error validated = constraint:validate(emailValue);
    if validated is error {
        return error(string `Customer email '${rawEmail}' is invalid: ${validated.message()}`);
    }
    string email = validated;

    // Query QB for existing customer by email (QB IDS uses backslash-escape for single quotes, not SQL doubling)
    string sanitizedEmail = string:'join("\\'", ...re `'`.split(email));
    string query = string `SELECT Id FROM Customer WHERE PrimaryEmailAddr = '${sanitizedEmail}'`;
    json|error queryResult = quickbooksClient->queryEntity(quickbooksConfig.realmId, query);
    if queryResult is map<json> {
        json? qr = queryResult["QueryResponse"];
        if qr is map<json> {
            json? customers = qr["Customer"];
            if customers is json[] && customers.length() > 0 {
                json firstCustomer = customers[0];
                if firstCustomer is map<json> {
                    json? customerId = firstCustomer["Id"];
                    if customerId !is () {
                        string id = customerId.toString();
                        log:printInfo("Found existing QB customer: " + id + " for email: " + email);
                        return id;
                    }
                }
            }
        }
    }

    // Not found — auto-create if enabled
    if !quickbooksConfig.createCustomerIfNotFound {
        return error(string `QB customer not found for email: ${email}. Auto-creation disabled.`);
    }

    string firstName = customer?.first_name ?: "";
    string lastName = customer?.last_name ?: "";
    string displayName = (firstName + " " + lastName).trim();
    if displayName == "" {
        displayName = email;
    }

    quickbooks:CustomerCreateObject newCustomer = {
        DisplayName: displayName,
        GivenName: firstName == "" ? () : firstName,
        FamilyName: lastName == "" ? () : lastName,
        PrimaryEmailAddr: {Address: email},
        BillAddr: buildPhysicalAddress(billingAddr)
    };

    quickbooks:CustomerResponse createResult = check quickbooksClient->createOrUpdateCustomer(
        quickbooksConfig.realmId, newCustomer);

    json crJson = createResult.toJson();
    if crJson is map<json> {
        json? customerObj = crJson["Customer"];
        if customerObj is map<json> {
            json? customerId = customerObj["Id"];
            if customerId !is () {
                string newId = customerId.toString();
                log:printInfo("Created new QB customer: " + newId + " for email: " + email);
                return newId;
            }
            return error("Created QB customer has no Id in response");
        }
    }
    return error("Created QB customer response has no Customer object or is malformed");

}

// --- Lookup QB item ID by Shopify SKU ---
function lookupQBItemId(string? sku) returns string|error {
    if sku is () || sku == "" {
        return error("Product SKU is null or empty");
    }
    if productMap.hasKey(sku) {
        return productMap.get(sku);
    }
    // Fallback: query QB by Name (Sku field is not queryable for all item types; QB IDS uses backslash-escape)
    string sanitizedSku = string:'join("\\'", ...re `'`.split(sku));
    string query = string `SELECT Id FROM Item WHERE Name = '${sanitizedSku}'`;
    json|error queryResult = quickbooksClient->queryEntity(quickbooksConfig.realmId, query);
    if queryResult is map<json> {
        json? qr = queryResult["QueryResponse"];
        if qr is map<json> {
            json? items = qr["Item"];
            if items is json[] && items.length() > 0 {
                json firstItem = items[0];
                if firstItem is map<json> {
                    json? itemId = firstItem["Id"];
                    if itemId !is () {
                        return itemId.toString();
                    }
                }
            }
        }
    }
    return error(string `No QuickBooks item found for SKU: ${sku}`);
}

// --- Tax code resolution ---
function resolveTaxCode(shopify:TaxLine[]? taxLines) returns string {
    if taxLines is () || taxLines.length() == 0 {
        return quickbooksConfig.taxConfig.defaultTaxCode;
    }
    string taxName = taxLines[0]?.title ?: "";
    if taxName == "" {
        return quickbooksConfig.taxConfig.defaultTaxCode;
    }
    json|error parsed = quickbooksConfig.taxConfig.taxMappingJson.fromJsonString();
    if parsed is map<json> {
        json? taxCodeValue = parsed[taxName];
        if taxCodeValue !is () {
            return taxCodeValue.toString();
        }
    }
    return quickbooksConfig.taxConfig.defaultTaxCode;
}

// --- Format ISO datetime to YYYY-MM-DD for QB TxnDate ---
function formatTxnDate(string? isoDate) returns string {
    if isoDate is () || isoDate == "" {
        return todayAsYYYYMMDD();
    }
    string[] parts = re `-`.split(isoDate);
    if parts.length() >= 3 {
        string dayPart = parts[2].length() >= 2 ? parts[2].substring(0, 2) : parts[2];
        int|error yr = int:fromString(parts[0]);
        int|error mo = int:fromString(parts[1]);
        int|error dy = int:fromString(dayPart);
        if yr is int && mo is int && dy is int && mo >= 1 && mo <= 12 && dy >= 1 && dy <= 31 {
            return string `${yr}-${mo < 10 ? "0" : ""}${mo}-${dy < 10 ? "0" : ""}${dy}`;
        }
    }
    // Malformed date — fall back to today so QB always receives a valid YYYY-MM-DD
    log:printWarn(string `[formatTxnDate] Malformed date '${isoDate}'; using today as fallback`);
    return todayAsYYYYMMDD();
}

function todayAsYYYYMMDD() returns string {
    time:Civil now = time:utcToCivil(time:utcNow());
    int mo = now.month;
    int dy = now.day;
    return string `${now.year}-${mo < 10 ? "0" : ""}${mo}-${dy < 10 ? "0" : ""}${dy}`;
}

// --- Build PrivateNote memo from order ---
function buildMemo(shopify:OrderEvent event) returns string {
    if !quickbooksConfig.addOrderReferenceToMemo {
        return "";
    }
    string orderId = (event?.id ?: 0).toString();
    int? orderNumInt = event?.order_number;
    string orderNum = orderNumInt is int ? orderNumInt.toString() : orderId;
    return string `Shopify Order: ${orderNum} | ID: ${orderId}`;
}

// --- Build QB PhysicalAddress from Shopify CustomerAddress ---
// CustomerAddress uses quoted field names: 'address1?, 'address2?
function buildPhysicalAddress(shopify:CustomerAddress? addr) returns quickbooks:PhysicalAddress? {
    if addr is () {
        return ();
    }
    return {
        Line1: addr?.'address1,
        City: addr?.city,
        CountrySubDivisionCode: addr?.province,
        PostalCode: addr?.zip,
        Country: addr?.country
    };
}

// --- Quarantine: log and persist an order that cannot be processed ---
function quarantineOrder(shopify:OrderEvent event, string reason, string errorType) {
    int? orderNum = event?.order_number;
    QuarantinedOrder quarantined = {
        orderId: (event?.id ?: 0).toString(),
        orderNumber: orderNum is int ? orderNum.toString() : "N/A",
        quarantineReason: reason,
        errorType: errorType,
        timestamp: time:utcNow().toString(),
        retryEligible: errorType != "VALIDATION"
    };
    log:printWarn(string `[QUARANTINE] Order ${quarantined.orderNumber} | ${quarantined.errorType}: ${quarantined.quarantineReason}`);
    persistQuarantinedOrder(quarantined);
}

// Persists a quarantined order so it is not lost on restart and can be picked up by retry or manual-review workflows.
// TODO: Replace this placeholder with a durable store (database table, dead-letter queue, or message broker)
//       that preserves retryEligible and timestamp so downstream processes can act on them.
function persistQuarantinedOrder(QuarantinedOrder quarantined) {
    log:printWarn(string `[QUARANTINE][PERSIST] orderId=${quarantined.orderId} orderNumber=${quarantined.orderNumber} ` +
        string `errorType=${quarantined.errorType} retryEligible=${quarantined.retryEligible} ` +
        string `timestamp=${quarantined.timestamp} reason=${quarantined.quarantineReason}`);
}

// --- Helper to safely convert int? order_number to string ---
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

// --- Safely extract the QB-assigned Id from a toJson() response ---
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

// In-memory idempotency barrier: tracks order IDs currently in-flight (false) or successfully created in QB (true).
// Prevents concurrent duplicate creation when onOrdersFulfilled and onOrdersPaid both fire for the same order.
// LIMITATION: scoped to the current process instance — does not protect against duplicates across replicas.
// For multi-replica deployments use one of:
//   • Sticky webhook routing keyed by order ID (same replica always handles a given order), or
//   • A distributed idempotency store (Redis SET NX, shared DB table with UNIQUE constraint on order_id), or
//   • Rely solely on the persistent isDuplicateTransaction QB query as the idempotency gate.
// TODO: Replace with a distributed lock/cache if this service runs with more than one replica.
final map<boolean> processedOrderIds = {};

// --- Core order processing pipeline ---
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

