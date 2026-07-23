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

    string? accountName = account["Name"] is string ? <string>account["Name"] : ();
    string? email = account["Email__c"] is string ? <string>account["Email__c"] : ();
    string? phone = account["Phone"] is string ? <string>account["Phone"] : ();
    string? description = account["Description"] is string ? <string>account["Description"] : ();
    
    putIfNonEmpty(payload, "name", accountName);
    putIfNonEmpty(payload, "email", email);
    putIfNonEmpty(payload, "phone", phone);
    putIfNonEmpty(payload, "description", description);

    // Shipping Address -> Stripe shipping.address field
    string? shippingStreet = account["ShippingStreet"] is string ? <string>account["ShippingStreet"] : ();
    string? shippingCity = account["ShippingCity"] is string ? <string>account["ShippingCity"] : ();
    string? shippingState = account["ShippingState"] is string ? <string>account["ShippingState"] : ();
    string? shippingPostalCode = account["ShippingPostalCode"] is string ? <string>account["ShippingPostalCode"] : ();
    string? shippingCountry = account["ShippingCountry"] is string ? <string>account["ShippingCountry"] : ();
    
    map<json>? shippingAddress = buildAddress(
        shippingStreet,
        shippingCity,
        shippingState,
        shippingPostalCode,
        shippingCountry
    );
    if shippingAddress is map<json> {
        map<json> shipping = {
            "address": shippingAddress
        };
        putIfNonEmpty(shipping, "name", accountName);
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
    string firstName = contact["FirstName"] is string ? <string>contact["FirstName"] : "";
    string lastName = contact["LastName"] is string ? <string>contact["LastName"] : "";
    string fullName = (firstName + " " + lastName).trim();
    
    string? email = contact["Email"] is string ? <string>contact["Email"] : ();
    string? phone = contact["Phone"] is string ? <string>contact["Phone"] : ();
    string? description = contact["Description"] is string ? <string>contact["Description"] : ();

    putIfNonEmpty(payload, "name", fullName);
    putIfNonEmpty(payload, "email", email);
    putIfNonEmpty(payload, "phone", phone);
    putIfNonEmpty(payload, "description", description);

    // Mailing Address -> Shipping Address (shipping.address)
    string? mailingStreet = contact["MailingStreet"] is string ? <string>contact["MailingStreet"] : ();
    string? mailingCity = contact["MailingCity"] is string ? <string>contact["MailingCity"] : ();
    string? mailingState = contact["MailingState"] is string ? <string>contact["MailingState"] : ();
    string? mailingPostalCode = contact["MailingPostalCode"] is string ? <string>contact["MailingPostalCode"] : ();
    string? mailingCountry = contact["MailingCountry"] is string ? <string>contact["MailingCountry"] : ();
    
    map<json>? shippingAddress = buildAddress(
        mailingStreet,
        mailingCity,
        mailingState,
        mailingPostalCode,
        mailingCountry
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
    if syncConfig.recordTypeFilter.length() > 0 {
        if recordTypeId is () {
            log:printDebug("Record filtered out: No RecordTypeId");
            return false;
        }
        boolean recordTypeMatch = false;
        foreach string allowedType in syncConfig.recordTypeFilter {
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
    if syncConfig.accountStatusFilter.length() > 0 {
        if accountStatus is () {
            log:printDebug("Record filtered out: No AccountStatus");
            return false;
        }
        boolean statusMatch = false;
        foreach string allowedStatus in syncConfig.accountStatusFilter {
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