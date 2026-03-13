import ballerina/log;
import ballerina/time;
import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// --- Parsed product SKU → QB item ID map (loaded once at module init) ---
final map<string> & readonly productMap = check loadProductMap();

function loadProductMap() returns map<string> & readonly|error {
    log:printInfo("[Config] productMappingJson = " + productMappingJson);
    json parsed = check (productMappingJson).fromJsonString();
    map<string> m = {};
    map<json> jsonMap = <map<json>>parsed;
    foreach var [k, v] in jsonMap.entries() {
        m[k] = v.toString();
    }
    log:printInfo("[Config] productMap loaded with " + m.length().toString() + " entries: " + m.toString());
    return m.cloneReadOnly();
}

// --- Order status filter ---
function shouldProcessOrder(shopify:OrderEvent event) returns boolean {
    match orderStatusTrigger {
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
    }
    return false;
}

// --- Duplicate check: query QB for an existing Invoice with this order number in PrivateNote ---
function isDuplicateTransaction(string orderNum) returns boolean|error {
    if orderNum.length() == 0 {
        return false;
    }
    string query = string `SELECT Id FROM Invoice WHERE PrivateNote LIKE '%Shopify Order: ${orderNum}%'`;
    json|error result = quickbooksClient->queryEntity(quickbooksConfig.realmId, query);
    if result is error {
        log:printWarn("Duplicate check failed, assuming not duplicate: " + result.message());
        return false;
    }
    json|error queryResponse = result.QueryResponse;
    if queryResponse is error || queryResponse is () {
        return false;
    }
    json|error invoices = queryResponse.Invoice;
    if invoices is error || invoices is () {
        return false;
    }
    if invoices is json[] {
        return invoices.length() > 0;
    }
    return false;
}

// --- Customer lookup / auto-creation ---
// OrderEvent.customer is shopify:Customer? and OrderEvent.billing_address is shopify:CustomerAddress?
function getOrCreateQBCustomer(shopify:Customer? customer, shopify:CustomerAddress? billingAddr) returns string|error {
    string? email = customer?.email;
    if email is () || email == "" {
        if validationRules.requireCustomerEmail {
            return error("Customer email is required but missing");
        }
        return "DEFAULT_CUSTOMER";
    }

    // Query QB for existing customer by email
    string query = string `SELECT Id FROM Customer WHERE PrimaryEmailAddr = '${email}'`;
    json|error queryResult = quickbooksClient->queryEntity(quickbooksConfig.realmId, query);
    if queryResult is json {
        json|error qr = queryResult.QueryResponse;
        if qr is json {
            json|error customers = qr.Customer;
            if customers is json[] && customers.length() > 0 {
                json firstCustomer = customers[0];
                json|error customerId = firstCustomer.Id;
                if customerId is json {
                    string id = customerId.toString();
                    log:printInfo("Found existing QB customer: " + id + " for email: " + email);
                    return id;
                }
            }
        }
    }

    // Not found — auto-create if enabled
    if !createCustomerIfNotFound {
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
    json|error customerObj = crJson.Customer;
    if customerObj is error || customerObj is () {
        return error("Created QB customer response has no Customer object");
    }
    json|error customerId = customerObj.Id;
    if customerId is error || customerId is () {
        return error("Created QB customer has no Id in response");
    }
    string newId = customerId.toString();
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
    // Fallback: query QB by Name (Sku field is not queryable for all item types)
    string query = string `SELECT Id FROM Item WHERE Name = '${sku}'`;
    json|error queryResult = quickbooksClient->queryEntity(quickbooksConfig.realmId, query);
    if queryResult is json {
        json|error qr = queryResult.QueryResponse;
        if qr is json {
            json|error items = qr.Item;
            if items is json[] && items.length() > 0 {
                json firstItem = items[0];
                json|error itemId = firstItem.Id;
                if itemId is json {
                    return itemId.toString();
                }
            }
        }
    }
    return error(string `No QuickBooks item found for SKU: ${sku}`);
}

// --- Tax code resolution ---
function resolveTaxCode(shopify:TaxLine[]? taxLines) returns string {
    if taxLines is () || taxLines.length() == 0 {
        return taxConfig.defaultTaxCode;
    }
    string taxName = taxLines[0]?.title ?: "";
    if taxName == "" {
        return taxConfig.defaultTaxCode;
    }
    json|error parsed = taxConfig.taxMappingJson.fromJsonString();
    if parsed is json {
        map<json>|error parsedMap = parsed.ensureType();
        if parsedMap is map<json> && parsedMap.hasKey(taxName) {
            json taxCodeValue = parsedMap[taxName];
            return taxCodeValue.toString();
        }
    }
    return taxConfig.defaultTaxCode;
}

// --- Format ISO datetime to YYYY-MM-DD for QB TxnDate ---
function formatTxnDate(string? isoDate) returns string {
    if isoDate is () || isoDate == "" {
        time:Civil now = time:utcToCivil(time:utcNow());
        int mo = now.month;
        int dy = now.day;
        return string `${now.year}-${mo < 10 ? "0" : ""}${mo}-${dy < 10 ? "0" : ""}${dy}`;
    }
    string[] parts = re `-`.split(isoDate);
    if parts.length() >= 3 {
        string day = parts[2].length() >= 2 ? parts[2].substring(0, 2) : parts[2];
        return parts[0] + "-" + parts[1] + "-" + day;
    }
    return isoDate;
}

// --- Build PrivateNote memo from order ---
function buildMemo(shopify:OrderEvent event) returns string {
    if !addOrderReferenceToMemo {
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

// --- Quarantine: log an order that cannot be processed ---
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
}
