import ballerina/log;

// Helper function to add non-empty values to a map
isolated function putIfNonEmpty(map<json> target, string key, string? value) {
    if value is string && value != "" {
        target[key] = value;
    }
}

// Helper function to build address map from components
isolated function buildAddress(
    string? street,
    string? city,
    string? state,
    string? postalCode,
    string? country
) returns map<json>? {
    map<json> address = {};

    putIfNonEmpty(address, "line1", street);
    putIfNonEmpty(address, "city", city);
    putIfNonEmpty(address, "state", state);
    putIfNonEmpty(address, "postal_code", postalCode);
    putIfNonEmpty(address, "country", country);

    return address.length() > 0 ? address : ();
}

// Map Salesforce Account to Stripe Customer
public isolated function mapAccountToStripeCustomer(SalesforceAccount account) returns record {} {
    map<json> payload = {
        "metadata": {
            "salesforce_id": account?.Id ?: "",
            "source": "salesforce_account"
        }
    };

    putIfNonEmpty(payload, "name", account?.Name);
    putIfNonEmpty(payload, "email", account?.Email__c);
    putIfNonEmpty(payload, "phone", account?.Phone);
    putIfNonEmpty(payload, "description", account?.Description);

    // Shipping Address -> Stripe shipping.address field
    map<json>? shippingAddress = buildAddress(
        account?.ShippingStreet,
        account?.ShippingCity,
        account?.ShippingState,
        account?.ShippingPostalCode,
        account?.ShippingCountry
    );
    if shippingAddress is map<json> {
        map<json> shipping = {
            "address": shippingAddress
        };
        putIfNonEmpty(shipping, "name", account?.Name);
        payload["shipping"] = shipping;
    }

    return payload;
}

// Map Salesforce Contact to Stripe Customer
public isolated function mapContactToStripeCustomer(SalesforceContact contact) returns record {} {
    map<json> payload = {
        "metadata": {
            "salesforce_id": contact?.Id ?: "",
            "source": "salesforce_contact"
        }
    };

    // Build full name from first and last name
    string firstName = contact?.FirstName ?: "";
    string lastName = contact?.LastName ?: "";
    string fullName = (firstName + " " + lastName).trim();

    putIfNonEmpty(payload, "name", fullName);
    putIfNonEmpty(payload, "email", contact?.Email);
    putIfNonEmpty(payload, "phone", contact?.Phone);
    putIfNonEmpty(payload, "description", contact?.Description);

    // Mailing Address -> Shipping Address (shipping.address)
    map<json>? shippingAddress = buildAddress(
        contact?.MailingStreet,
        contact?.MailingCity,
        contact?.MailingState,
        contact?.MailingPostalCode,
        contact?.MailingCountry
    );
    if shippingAddress is map<json> {
        map<json> shipping = {
            "address": shippingAddress
        };
        putIfNonEmpty(shipping, "name", fullName);
        payload["shipping"] = shipping;
    }

    return payload;
}

// Check if record passes filters
public function passFilters(string? recordTypeId, string? accountStatus) returns boolean {
    // Check RecordType filter
    if recordTypeFilter.length() > 0 {
        if recordTypeId is () {
            log:printDebug("Record filtered out: No RecordTypeId");
            return false;
        }
        boolean recordTypeMatch = false;
        foreach string allowedType in recordTypeFilter {
            if recordTypeId == allowedType {
                recordTypeMatch = true;
                break;
            }
        }
        if !recordTypeMatch {
            log:printDebug("Record filtered out: RecordTypeId does not match filter");
            return false;
        }
    }

    // Check AccountStatus filter
    if accountStatusFilter.length() > 0 {
        if accountStatus is () {
            log:printDebug("Record filtered out: No AccountStatus");
            return false;
        }
        boolean statusMatch = false;
        foreach string allowedStatus in accountStatusFilter {
            if accountStatus == allowedStatus {
                statusMatch = true;
                break;
            }
        }
        if !statusMatch {
            log:printDebug("Record filtered out: AccountStatus does not match filter");
            return false;
        }
    }

    return true;
}