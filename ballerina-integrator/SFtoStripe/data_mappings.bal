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
    
    if account?.Email__c is string { payload["email"] = account?.Email__c; }
    if account?.Phone is string { payload["phone"] = account?.Phone; }
    if account?.Description is string { payload["description"] = account?.Description; }

    map<json> address = {};
    if account?.BillingStreet is string { address["line1"] = account?.BillingStreet; }
    if account?.BillingCity is string { address["city"] = account?.BillingCity; }
    if account?.BillingState is string { address["state"] = account?.BillingState; }
    if account?.BillingPostalCode is string { address["postal_code"] = account?.BillingPostalCode; }
    if account?.BillingCountry is string { address["country"] = account?.BillingCountry; }
    if address.length() > 0 { payload["address"] = address; }

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
    log:printInfo("[mapContactToStripeCustomer] Building name", firstName = firstName, lastName = lastName, fullName = fullName);
    if fullName != "" {
        payload["name"] = fullName;
    }
    
    if contact?.Email is string { payload["email"] = contact?.Email; }
    if contact?.Phone is string { payload["phone"] = contact?.Phone; }
    if contact?.Description is string { payload["description"] = contact?.Description; }

    map<json> address = {};
    if contact?.MailingStreet is string { address["line1"] = contact?.MailingStreet; }
    if contact?.MailingCity is string { address["city"] = contact?.MailingCity; }
    if contact?.MailingState is string { address["state"] = contact?.MailingState; }
    if contact?.MailingPostalCode is string { address["postal_code"] = contact?.MailingPostalCode; }
    if contact?.MailingCountry is string { address["country"] = contact?.MailingCountry; }
    if address.length() > 0 { payload["address"] = address; }

    return payload;
}

// Check if record passes filters
public isolated function passesFilters(string? recordTypeId, string? accountStatus) returns boolean {
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