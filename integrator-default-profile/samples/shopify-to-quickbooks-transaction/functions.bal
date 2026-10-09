import ballerina/constraint;
import ballerina/log;
import ballerina/time;
import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// --- Parsed product SKU → QB item ID map (loaded once at module init) ---
final map<string> & readonly productMap = check loadProductMap();

// #4: Parsed tax name → QB tax code map (loaded once at module init to avoid re-parsing per line item)
final map<string> & readonly taxCodeMap = check loadTaxCodeMap();

// #10: Use early return pattern
function loadProductMap() returns map<string> & readonly|error {
    log:printInfo("[Config] productMappingJson = " + quickbooksConfig.productMappingJson);
    json parsed = check (quickbooksConfig.productMappingJson).fromJsonString();

    if parsed !is map<json> {
        return error("[Config] Invalid productMappingJson: expected a JSON object mapping product SKUs to QuickBooks item IDs");
    }

    map<string> m = {};
    foreach var [k, v] in parsed.entries() {
        m[k] = v.toString();
    }
    log:printInfo("[Config] productMap loaded with " + m.length().toString() + " entries: " + m.toString());
    return m.cloneReadOnly();
}

function loadTaxCodeMap() returns map<string> & readonly|error {
    json parsed = check (quickbooksConfig.taxConfig.taxMappingJson).fromJsonString();

    if parsed !is map<json> {
        log:printWarn("[Config] Invalid taxMappingJson: expected a JSON object; falling back to defaultTaxCode for all items");
        return {}.cloneReadOnly();
    }

    map<string> m = {};
    foreach var [k, v] in parsed.entries() {
        m[k] = v.toString();
    }
    log:printInfo("[Config] taxCodeMap loaded with " + m.length().toString() + " entries");
    return m.cloneReadOnly();
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
            // #11: Warn before silently ignoring unrecognized trigger
            log:printWarn(string `[Config] Unrecognized orderStatusTrigger: '${shopifyConfig.orderStatusTrigger}'; no orders will be processed`);
            return false;
        }
    }
}

// --- Duplicate check: query QB for an existing Invoice with this order number in PrivateNote ---
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

    // Query QB for existing customer by email
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

    // #7: Use extractQBId helper
    string newId = extractQBId(createResult.toJson(), "Customer");
    if newId == "unknown" {
        return error("Created QB customer has no Id in response");
    }
    log:printInfo("Created new QB customer: " + newId + " for email: " + email);
    return newId;
}

// --- Lookup QB item ID by Shopify SKU ---
function lookupQBItemId(string? sku) returns string|error {
    if sku is () || sku == "" {
        return error("Product SKU is null or empty");
    }
    if productMap.hasKey(sku) {
        return productMap.get(sku);
    }
    // Fallback: query QB by Name
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

// #4: Tax code resolution using pre-parsed map (no per-line-item parsing)
function resolveTaxCode(shopify:TaxLine[]? taxLines) returns string {
    if taxLines is () || taxLines.length() == 0 {
        return quickbooksConfig.taxConfig.defaultTaxCode;
    }
    string taxName = taxLines[0]?.title ?: "";
    if taxName == "" {
        return quickbooksConfig.taxConfig.defaultTaxCode;
    }
    // Use the pre-loaded taxCodeMap instead of re-parsing JSON
    if taxCodeMap.hasKey(taxName) {
        return taxCodeMap.get(taxName);
    }
    return quickbooksConfig.taxConfig.defaultTaxCode;
}

// #6: Use .padZero(2) for zero-padding
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
    log:printWarn(string `[formatTxnDate] Malformed date '${isoDate}'; using today as fallback`);
    return todayAsYYYYMMDD();
}

function todayAsYYYYMMDD() returns string {
    time:Civil now = time:utcToCivil(time:utcNow());
    return string `${now.year}-${now.month < 10 ? "0" : ""}${now.month}-${now.day < 10 ? "0" : ""}${now.day}`;
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

// #12: addr itself is nil-checked, but its fields are still optional so we keep optional field access
function buildPhysicalAddress(shopify:CustomerAddress? addr) returns quickbooks:PhysicalAddress? {
    if addr is () {
        return ();
    }
    // addr is guaranteed non-nil, but fields within CustomerAddress are still optional types
    return {
        Line1: addr?.'address1,
        City: addr?.city,
        CountrySubDivisionCode: addr?.province,
        PostalCode: addr?.zip,
        Country: addr?.country
    };
}

// #9: Log directly without constructing QuarantinedOrder record
function quarantineOrder(shopify:OrderEvent event, string reason, string errorType) {
    string orderId = (event?.id ?: 0).toString();
    int? orderNum = event?.order_number;
    string orderNumber = orderNum is int ? orderNum.toString() : "N/A";
    string timestamp = time:utcNow().toString();
    boolean retryEligible = errorType != "VALIDATION";

    log:printWarn(string `[QUARANTINE] Order ${orderNumber} | ${errorType}: ${reason}`);
    log:printWarn(string `[QUARANTINE][PERSIST] orderId=${orderId} orderNumber=${orderNumber} ` +
        string `errorType=${errorType} retryEligible=${retryEligible} timestamp=${timestamp} reason=${reason}`);
}

// --- Helper to safely convert int? order_number to string ---
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

// #8: Helper to release order lock (used in multiple skip/error paths)
function releaseOrderLock(string orderId) {
    lock { _ = processedOrderIds.removeIfHasKey(orderId); }
}

// In-memory idempotency barrier
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
        // 1. Status filter
        if !shouldProcessOrder(event) {
            log:printInfo(string `[Skip] Order #${orderNum}: status does not match trigger '${shopifyConfig.orderStatusTrigger}'`);
            releaseOrderLock(orderId);
            return;
        }

        // 2. Minimum amount validation
        string? totalStr = event?.total_price;
        if totalStr is () {
            if quickbooksConfig.validationRules.minimumOrderAmount > 0d {
                log:printWarn(string `[Skip] Order #${orderNum}: total_price is null and minimumOrderAmount is ${quickbooksConfig.validationRules.minimumOrderAmount}; rejecting order.`);
                releaseOrderLock(orderId);
                return;
            }
        } else {
            decimal total = check decimal:fromString(totalStr);
            if total < quickbooksConfig.validationRules.minimumOrderAmount {
                log:printInfo(string `[Skip] Order #${orderNum}: total ${total} below minimum ${quickbooksConfig.validationRules.minimumOrderAmount}`);
                releaseOrderLock(orderId);
                return;
            }
        }

        // 3. Required fields validation
        shopify:OrderLineItem[]? lineItems = event?.line_items;
        if quickbooksConfig.validationRules.requireLineItems && (lineItems is () || lineItems.length() == 0) {
            quarantineOrder(event, "Order has no line items", "VALIDATION");
            releaseOrderLock(orderId);
            return;
        }

        // 4. Duplicate prevention
        boolean duplicate = check isDuplicateTransaction(orderNum);
        if duplicate {
            log:printInfo(string `[Skip] Order #${orderNum}: already synced to QuickBooks (duplicate)`);
            lock { processedOrderIds[orderId] = true; }
            return;
        }

        // 5. Get or create QuickBooks customer
        string customerId = check getOrCreateQBCustomer(event?.customer, event?.billing_address);

        // 6. Build and create QuickBooks Invoice
        quickbooks:InvoiceCreateObject qbInvoice = check mapToQBTransaction(event, customerId);
        quickbooks:InvoiceResponse qbResult = check quickbooksClient->createOrUpdateInvoice(
            quickbooksConfig.realmId, qbInvoice);

        string idStr = extractQBId(qbResult.toJson(), "Invoice");
        string docType = quickbooksConfig.transactionType == "INVOICE" ? "Invoice" : "Sales Receipt (as Invoice)";

        // #5: Mark as successfully completed (required for idempotency across webhook retries)
        lock { processedOrderIds[orderId] = true; }
        log:printInfo(string `[QB] ${docType} created: Id=${idStr} for Order #${orderNum}`);

    } on fail error e {
        releaseOrderLock(orderId);
        log:printError(string `[Error] Failed to process Order #${orderNum}: ${e.message()}`, 'error = e);
        quarantineOrder(event, e.message(), "UNKNOWN_ERROR");
        return e;
    }
}
