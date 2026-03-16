import ballerina/log;

// Map Salesforce Account to Stripe Customer
public isolated function mapAccountToStripeCustomer(SalesforceAccount account) returns record {} {
    map<json> payload = {
        "metadata": {
            "salesforce_id": account?.Id ?: "",
            "source": "salesforce_account"
        }
    };
    
    // Only include name if it's not empty
    if account?.Name is string && account?.Name != "" {
        payload["name"] = account?.Name;
    }
    
    if account?.Email__c is string && account?.Email__c != "" { payload["email"] = account?.Email__c; }
    if account?.Phone is string { payload["phone"] = account?.Phone; }
    if account?.Description is string { payload["description"] = account?.Description; }

    // Billing Address -> Stripe address field
    map<json> billingAddress = {};
    if account?.BillingStreet is string && account?.BillingStreet != "" { billingAddress["line1"] = account?.BillingStreet; }
    if account?.BillingCity is string && account?.BillingCity != "" { billingAddress["city"] = account?.BillingCity; }
    if account?.BillingState is string && account?.BillingState != "" { billingAddress["state"] = account?.BillingState; }
    if account?.BillingPostalCode is string && account?.BillingPostalCode != "" { billingAddress["postal_code"] = account?.BillingPostalCode; }
    if account?.BillingCountry is string && account?.BillingCountry != "" { billingAddress["country"] = account?.BillingCountry; }
    if billingAddress.length() > 0 { payload["address"] = billingAddress; }

    // Shipping Address -> Stripe shipping.address field
    map<json> shippingAddress = {};
    if account?.ShippingStreet is string && account?.ShippingStreet != "" { shippingAddress["line1"] = account?.ShippingStreet; }
    if account?.ShippingCity is string && account?.ShippingCity != "" { shippingAddress["city"] = account?.ShippingCity; }
    if account?.ShippingState is string && account?.ShippingState != "" { shippingAddress["state"] = account?.ShippingState; }
    if account?.ShippingPostalCode is string && account?.ShippingPostalCode != "" { shippingAddress["postal_code"] = account?.ShippingPostalCode; }
    if account?.ShippingCountry is string && account?.ShippingCountry != "" { shippingAddress["country"] = account?.ShippingCountry; }
    if shippingAddress.length() > 0 {
        map<json> shipping = {"address": shippingAddress};
        // Add name to shipping if available
        if account?.Name is string && account?.Name != "" {
            shipping["name"] = account?.Name;
        }
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
    
    // Only include name if first or last name is present
    string firstName = contact?.FirstName ?: "";
    string lastName = contact?.LastName ?: "";
    string fullName = (firstName + " " + lastName).trim();

    if fullName != "" {
        payload["name"] = fullName;
    }
    
    if contact?.Email is string && contact?.Email != "" { payload["email"] = contact?.Email; }
    if contact?.Phone is string && contact?.Phone != "" { payload["phone"] = contact?.Phone; }
    if contact?.Description is string { payload["description"] = contact?.Description; }

    // Mailing Address -> Billing Address (address)
    map<json> billingAddress = {};
    if contact?.MailingStreet is string && contact?.MailingStreet != "" { billingAddress["line1"] = contact?.MailingStreet; }
    if contact?.MailingCity is string && contact?.MailingCity != "" { billingAddress["city"] = contact?.MailingCity; }
    if contact?.MailingState is string && contact?.MailingState != "" { billingAddress["state"] = contact?.MailingState; }
    if contact?.MailingPostalCode is string && contact?.MailingPostalCode != "" { billingAddress["postal_code"] = contact?.MailingPostalCode; }
    if contact?.MailingCountry is string && contact?.MailingCountry != "" { billingAddress["country"] = contact?.MailingCountry; }
    if billingAddress.length() > 0 { payload["address"] = billingAddress; }

    // Other Address -> Shipping Address (shipping.address)
    map<json> shippingAddress = {};
    if contact?.OtherStreet is string && contact?.OtherStreet != "" { shippingAddress["line1"] = contact?.OtherStreet; }
    if contact?.OtherCity is string && contact?.OtherCity != "" { shippingAddress["city"] = contact?.OtherCity; }
    if contact?.OtherState is string && contact?.OtherState != "" { shippingAddress["state"] = contact?.OtherState; }
    if contact?.OtherPostalCode is string && contact?.OtherPostalCode != "" { shippingAddress["postal_code"] = contact?.OtherPostalCode; }
    if contact?.OtherCountry is string && contact?.OtherCountry != "" { shippingAddress["country"] = contact?.OtherCountry; }
    if shippingAddress.length() > 0 {
        map<json> shipping = {"address": shippingAddress};
        // Add name to shipping if available
        if fullName != "" {
            shipping["name"] = fullName;
        }
        payload["shipping"] = shipping;
    }

    return payload;
}

// Check if record passes filters
public function passesFilters(string? recordTypeId, string? accountStatus) returns boolean {
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