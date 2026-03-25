import ballerina/log;
import ballerinax/stripe;

// Sync Salesforce Account to Stripe
public function syncAccountToStripe(SalesforceAccount account, boolean isUpdate = false) returns error? {
    // Validate account data
    error? validationResult = validateAccount(account);
    if validationResult is error {
        log:printError("Account validation failed", accountId = account?.Id, 'error = validationResult);
        return validationResult;
    }

    // Check if record passes filters
    if !passFilters(account?.RecordTypeId, account?.AccountStatus__c) {
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
    
    // If no Stripe ID exists, search by match key
    if existingStripeId is () || existingStripeId == "" {
        string? foundStripeId = check searchStripeCustomerByMatchKey(account?.Id, account?.Email__c, ());
        if foundStripeId is string {
            existingStripeId = foundStripeId;
            log:printInfo("[syncAccountToStripe] Found existing Stripe customer by match key", stripeCustomerId = foundStripeId, matchKey = matchKey);
            
            // Write back the found Stripe ID to Salesforce
            if writeBackStripeId {
                string accountId = account?.Id ?: "";
                check writeBackStripeIdToSalesforce("Account", accountId, foundStripeId);
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
public function syncContactToStripe(SalesforceContact contact, boolean isUpdate = false) returns error? {
    // Validate contact data
    error? validationResult = validateContact(contact);
    if validationResult is error {
        log:printError("Contact validation failed", contactId = contact?.Id, 'error = validationResult);
        return validationResult;
    }

    // Check if record passes filters (only RecordType for contacts)
    if !passFilters(contact?.RecordTypeId, ()) {
        log:printInfo("Contact filtered out, skipping sync", contactId = contact?.Id);
        return;
    }

    // Map to Stripe customer payload
    record {} customerPayload = mapContactToStripeCustomer(contact);

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
    
    // If no Stripe ID exists, search by match key
    if existingStripeId is () || existingStripeId == "" {
        string? foundStripeId = check searchStripeCustomerByMatchKey(contact?.Id, contact?.Email, ());
        if foundStripeId is string {
            existingStripeId = foundStripeId;
            log:printInfo("[syncContactToStripe] Found existing Stripe customer by match key", stripeCustomerId = foundStripeId, matchKey = matchKey);
            
            // Write back the found Stripe ID to Salesforce
            if writeBackStripeId {
                string contactId = contact?.Id ?: "";
                check writeBackStripeIdToSalesforce("Contact", contactId, foundStripeId);
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
        string contactId = contact?.Id ?: "";
        log:printInfo("Creating new Stripe customer with idempotency key", contactId = contactId, idempotencyKey = contactId);
        stripe:customers_body payload = check customerPayload.cloneWithType();
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

    // Use Stripe Search API to find customer by metadata
    string searchQuery = string `metadata['salesforce_id']:'${salesforceId}'`;
    stripe:SearchResult_1|error searchResult = stripeClient->/customers/search.get(query = searchQuery);
    
    if searchResult is error {
        log:printError("Failed to search Stripe customers", salesforceId = salesforceId, 'error = searchResult);
        return searchResult;
    }
    
    if searchResult.data.length() > 0 {
        stripe:Customer customer = searchResult.data[0];
        log:printInfo("Found Stripe customer, deleting", stripeCustomerId = customer.id, salesforceId = salesforceId);
        stripe:Deleted_customer|error deleteResult = stripeClient->/customers/[customer.id].delete();
        if deleteResult is error {
            // Check if it's a 404 (customer already deleted)
            string errorMsg = deleteResult.message();
            if errorMsg.includes("Not Found") || errorMsg.includes("No such customer") {
                log:printWarn("Stripe customer already deleted", stripeCustomerId = customer.id, salesforceId = salesforceId);
                return;
            }
            // For other errors, propagate them
            return deleteResult;
        }
        log:printInfo("Successfully deleted Stripe customer", stripeCustomerId = customer.id);
        return;
    }
    
    log:printWarn("No Stripe customer found for salesforce_id, nothing to delete", salesforceId = salesforceId);
}

// Search for existing Stripe customer by match key
isolated function searchStripeCustomerByMatchKey(string? salesforceId, string? email, string? externalId) returns string?|error {
    if matchKey == EMAIL {
        // Search by email
        if email is () || email == "" {
            log:printDebug("[searchStripeCustomerByMatchKey] No email provided, cannot search by EMAIL match key");
            return ();
        }
        
        log:printInfo("[searchStripeCustomerByMatchKey] Searching by email", email = email);
        stripe:CustomerResourceCustomerList result = check stripeClient->/customers.get(email = email, 'limit = 1);
        
        if result.data.length() > 0 {
            string foundCustomerId = result.data[0].id;
            log:printInfo("[searchStripeCustomerByMatchKey] Found customer by email", stripeCustomerId = foundCustomerId, email = email);
            return foundCustomerId;
        }
        
        log:printInfo("[searchStripeCustomerByMatchKey] No customer found by email", email = email);
        return ();
    } else if matchKey == SALESFORCE_ID {
        // Search by Salesforce ID in metadata (salesforce_id)
        if salesforceId is () || salesforceId == "" {
            log:printDebug("[searchStripeCustomerByMatchKey] No Salesforce ID provided, cannot search by SALESFORCE_ID match key");
            return ();
        }
        
        log:printInfo("[searchStripeCustomerByMatchKey] Searching by salesforce_id metadata", salesforceId = salesforceId);
        
        // Use Stripe Search API to find customer by metadata
        string searchQuery = string `metadata['salesforce_id']:'${salesforceId}'`;
        stripe:SearchResult_1|error searchResult = stripeClient->/customers/search.get(query = searchQuery);
        
        if searchResult is error {
            log:printError("[searchStripeCustomerByMatchKey] Failed to search Stripe customers", salesforceId = salesforceId, 'error = searchResult);
            return searchResult;
        }
        
        if searchResult.data.length() > 0 {
            string foundCustomerId = searchResult.data[0].id;
            log:printInfo("[searchStripeCustomerByMatchKey] Found customer by salesforce_id", stripeCustomerId = foundCustomerId, salesforceId = salesforceId);
            return foundCustomerId;
        }
        
        log:printInfo("[searchStripeCustomerByMatchKey] No customer found by salesforce_id", salesforceId = salesforceId);
        return ();
    }
    
    return ();
}

// Delete Stripe Customer
public isolated function deleteStripeCustomer(string stripeCustomerId) returns error? {
    log:printInfo("Deleting Stripe customer", stripeCustomerId = stripeCustomerId);
    
    stripe:Deleted_customer|error deleteResult = stripeClient->/customers/[stripeCustomerId].delete();
    if deleteResult is error {
        // Check if it's a 404 (customer already deleted)
        string errorMsg = deleteResult.message();
        if errorMsg.includes("Not Found") || errorMsg.includes("No such customer") {
            log:printWarn("Stripe customer already deleted", stripeCustomerId = stripeCustomerId);
            return;
        }
        // For other errors, propagate them
        return deleteResult;
    }
    
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