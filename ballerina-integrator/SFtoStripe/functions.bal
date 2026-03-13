import ballerina/log;
import ballerinax/stripe;

// Sync Salesforce Account to Stripe
public isolated function syncAccountToStripe(SalesforceAccount account, boolean isUpdate = false) returns error? {
    // Validate account data
    error? validationResult = validateAccount(account);
    if validationResult is error {
        log:printError("Account validation failed", accountId = account?.Id, 'error = validationResult);
        return validationResult;
    }

    // Check if record passes filters
    if !passesFilters(account?.RecordTypeId, account?.AccountStatus__c) {
        log:printInfo("Account filtered out, skipping sync", accountId = account?.Id);
        return;
    }

    // Map to Stripe customer payload
    record {} customerPayload = mapAccountToStripeCustomer(account);

    // Check if customer already exists in Stripe
    string? existingStripeId = account?.Stripe_Customer_Id__c;
    
    // If this is a create event (not update) and no Stripe ID exists yet, 
    // re-fetch the account to check if another concurrent event already created the customer
    if !isUpdate && (existingStripeId is () || existingStripeId == "") {
        string accountId = account?.Id ?: "";
        string soqlQuery = string `SELECT Stripe_Customer_Id__c FROM Account WHERE Id = '${accountId}'`;
        stream<SalesforceAccount, error?> queryResult = check salesforceClient->query(soqlQuery);
        record {|SalesforceAccount value;|}? queryRecord = check queryResult.next();
        if queryRecord is record {|SalesforceAccount value;|} {
            string? refetchedStripeId = queryRecord.value?.Stripe_Customer_Id__c;
            if refetchedStripeId is string && refetchedStripeId != "" {
                log:printInfo("[syncAccountToStripe] Stripe ID already exists (concurrent event), skipping", accountId = accountId, stripeCustomerId = refetchedStripeId);
                return;
            }
        }
    }

    if existingStripeId is string && existingStripeId != "" {
        // Update existing customer
        log:printInfo("Updating existing Stripe customer", stripeCustomerId = existingStripeId);
        stripe:customers_customer_body payload = check customerPayload.cloneWithType();
        stripe:Customer updatedCustomer = check stripeClient->/customers/[existingStripeId].post(payload);
        log:printInfo("Successfully updated Stripe customer", stripeCustomerId = updatedCustomer.id);
    } else {
        // Create new customer with idempotency key (Stripe will deduplicate concurrent requests)
        // No need to search first - idempotency key handles race conditions
        string accountId = account?.Id ?: "";
        log:printInfo("Creating new Stripe customer with idempotency key", accountId = accountId, idempotencyKey = accountId);
        stripe:customers_body payload = check customerPayload.cloneWithType();
        stripe:Customer newCustomer = check stripeClient->/customers.post(payload, {"Idempotency-Key": accountId});
        log:printInfo("Successfully created Stripe customer", stripeCustomerId = newCustomer.id);

        // Write back Stripe ID to Salesforce if configured
        if writeBackStripeId {
            check writeBackStripeIdToSalesforce("Account", accountId, newCustomer.id);
        }
    }
}

// Sync Salesforce Contact to Stripe
public isolated function syncContactToStripe(SalesforceContact contact, boolean isUpdate = false) returns error? {
    // Validate contact data
    error? validationResult = validateContact(contact);
    if validationResult is error {
        log:printError("Contact validation failed", contactId = contact?.Id, 'error = validationResult);
        return validationResult;
    }

    // Check if record passes filters (only RecordType for contacts)
    if !passesFilters(contact?.RecordTypeId, ()) {
        log:printInfo("Contact filtered out, skipping sync", contactId = contact?.Id);
        return;
    }

    // Map to Stripe customer payload
    record {} customerPayload = mapContactToStripeCustomer(contact);
    log:printInfo("[syncContactToStripe] Raw payload from mapper", payload = customerPayload.toString());

    // Check if customer already exists in Stripe
    string? existingStripeId = contact?.Stripe_Customer_Id__c;
    
    // If this is a create event (not update) and no Stripe ID exists yet, 
    // re-fetch the contact to check if another concurrent event already created the customer
    if !isUpdate && (existingStripeId is () || existingStripeId == "") {
        string contactId = contact?.Id ?: "";
        string soqlQuery = string `SELECT Stripe_Customer_Id__c FROM Contact WHERE Id = '${contactId}'`;
        stream<SalesforceContact, error?> queryResult = check salesforceClient->query(soqlQuery);
        record {|SalesforceContact value;|}? queryRecord = check queryResult.next();
        if queryRecord is record {|SalesforceContact value;|} {
            string? refetchedStripeId = queryRecord.value?.Stripe_Customer_Id__c;
            if refetchedStripeId is string && refetchedStripeId != "" {
                log:printInfo("[syncContactToStripe] Stripe ID already exists (concurrent event), skipping", contactId = contactId, stripeCustomerId = refetchedStripeId);
                return;
            }
        }
    }

    if existingStripeId is string && existingStripeId != "" {
        // Update existing customer
        log:printInfo("Updating existing Stripe customer", stripeCustomerId = existingStripeId);
        stripe:customers_customer_body payload = check customerPayload.cloneWithType();
        log:printInfo("[syncContactToStripe] After cloneWithType, updating customer", payload = payload.toString());
        stripe:Customer updatedCustomer = check stripeClient->/customers/[existingStripeId].post(payload);
        log:printInfo("Successfully updated Stripe customer", stripeCustomerId = updatedCustomer.id);
    } else {
        // Create new customer with idempotency key (Stripe will deduplicate concurrent requests)
        // No need to search first - idempotency key handles race conditions
        string contactId = contact?.Id ?: "";
        log:printInfo("Creating new Stripe customer with idempotency key", contactId = contactId, idempotencyKey = contactId);
        stripe:customers_body payload = check customerPayload.cloneWithType();
        log:printInfo("[syncContactToStripe] After cloneWithType, creating new customer", payload = payload.toString());
        stripe:Customer newCustomer = check stripeClient->/customers.post(payload, {"Idempotency-Key": contactId});
        log:printInfo("Successfully created Stripe customer", stripeCustomerId = newCustomer.id);

        // Write back Stripe ID to Salesforce if configured
        if writeBackStripeId {
            check writeBackStripeIdToSalesforce("Contact", contactId, newCustomer.id);
        }
    }
}

// Write back Stripe Customer ID to Salesforce
isolated function writeBackStripeIdToSalesforce(string objectType, string recordId, string stripeCustomerId) returns error? {
    log:printInfo("Writing back Stripe ID to Salesforce", objectType = objectType, recordId = recordId, stripeCustomerId = stripeCustomerId);
    
    record {} updatePayload = {
        "Stripe_Customer_Id__c": stripeCustomerId
    };

    check salesforceClient->update(objectType, recordId, updatePayload);
    log:printInfo("Successfully wrote back Stripe ID to Salesforce");
}

// Delete Stripe customer by searching for salesforce_id in metadata
// Used when the SF record is already deleted and cannot be fetched
public isolated function deleteStripeCustomerBySalesforceId(string salesforceId) returns error? {
    log:printInfo("Looking up Stripe customer by salesforce_id", salesforceId = salesforceId);

    // Use pagination to search through ALL customers
    string? startingAfter = ();
    
    while true {
        stripe:CustomerResourceCustomerList result;
        if startingAfter is string {
            result = check stripeClient->/customers.get('limit = 100, starting_after = startingAfter);
        } else {
            result = check stripeClient->/customers.get('limit = 100);
        }
        
        foreach stripe:Customer c in result.data {
            map<string>? meta = c.metadata;
            if meta is map<string> && meta["salesforce_id"] == salesforceId {
                log:printInfo("Found Stripe customer, deleting", stripeCustomerId = c.id, salesforceId = salesforceId);
                _ = check stripeClient->/customers/[c.id].delete();
                log:printInfo("Successfully deleted Stripe customer", stripeCustomerId = c.id);
                return;
            }
        }
        
        // Check if there are more pages
        if result.has_more && result.data.length() > 0 {
            startingAfter = result.data[result.data.length() - 1].id;
            log:printInfo("[deleteStripeCustomerBySalesforceId] Fetching next page", startingAfter = startingAfter);
        } else {
            break; // No more pages
        }
    }
    
    log:printWarn("No Stripe customer found for salesforce_id, nothing to delete", salesforceId = salesforceId);
}

// Delete Stripe Customer
public isolated function deleteStripeCustomer(string stripeCustomerId) returns error? {
    log:printInfo("Deleting Stripe customer", stripeCustomerId = stripeCustomerId);
    
    _ = check stripeClient->/customers/[stripeCustomerId].delete();
    
    log:printInfo("Successfully deleted Stripe customer", stripeCustomerId = stripeCustomerId);
}

// Handle Salesforce Account deletion
public isolated function handleAccountDeletion(SalesforceAccount account) returns error? {
    string? stripeCustomerId = account?.Stripe_Customer_Id__c;
    
    if stripeCustomerId is () || stripeCustomerId == "" {
        log:printInfo("Account has no Stripe Customer ID, nothing to delete", accountId = account?.Id);
        return;
    }

    if deleteStripeCustomerOnSalesforceDelete {
        check deleteStripeCustomer(stripeCustomerId);
    } else {
        log:printInfo("Delete handling disabled, skipping Stripe customer deletion", stripeCustomerId = stripeCustomerId);
    }
}

// Handle Salesforce Contact deletion
public isolated function handleContactDeletion(SalesforceContact contact) returns error? {
    string? stripeCustomerId = contact?.Stripe_Customer_Id__c;
    
    if stripeCustomerId is () || stripeCustomerId == "" {
        log:printInfo("Contact has no Stripe Customer ID, nothing to delete", contactId = contact?.Id);
        return;
    }

    if deleteStripeCustomerOnSalesforceDelete {
        check deleteStripeCustomer(stripeCustomerId);
    } else {
        log:printInfo("Delete handling disabled, skipping Stripe customer deletion", stripeCustomerId = stripeCustomerId);
    }
}