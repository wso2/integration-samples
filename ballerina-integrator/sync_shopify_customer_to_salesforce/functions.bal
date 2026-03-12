import ballerina/log;
import ballerina/lang.regexp;
import ballerinax/salesforce;
import ballerinax/trigger.shopify;

// Escape single quotes for SOQL injection prevention
function escapeSoqlString(string input) returns string {
    regexp:RegExp singleQuotePattern = re `'`;
    return singleQuotePattern.replaceAll(input, "\\'");
}

// Check if contact exists by email (duplicate check)
public function findContactByEmail(string email) returns ContactQueryResult?|error {
    string escapedEmail = escapeSoqlString(email);
    string soqlQuery = string `SELECT Id, Email, FirstName, LastName, AccountId FROM Contact WHERE Email = '${escapedEmail}' LIMIT 1`;
    stream<ContactQueryResult, error?> resultStream = check salesforceClient->query(soql = soqlQuery);
    
    record {|ContactQueryResult value;|}? result = check resultStream.next();
    check resultStream.close();
    
    if result is record {|ContactQueryResult value;|} {
        return result.value;
    }
    return ();
}

// Find or create account based on company name or email domain
public function findOrCreateAccount(shopify:CustomerEvent customerEvent) returns string?|error {
    // Check if account association is disabled
    if accountAssociationRule == "none" {
        return ();
    }
    
    string? companyName = extractCompanyName(customerEvent);
    string? email = customerEvent?.email;
    
    // Try to find account by company name
    if (accountAssociationRule == "company" || accountAssociationRule == "domain") && companyName is string && companyName.trim() != "" {
        string escapedCompanyName = escapeSoqlString(companyName);
        string soqlQuery = string `SELECT Id, Name, Website FROM Account WHERE Name = '${escapedCompanyName}' LIMIT 1`;
        stream<AccountQueryResult, error?> resultStream = check salesforceClient->query(soql = soqlQuery);
        
        record {|AccountQueryResult value;|}? result = check resultStream.next();
        check resultStream.close();
        
        if result is record {|AccountQueryResult value;|} {
            log:printInfo("Found existing account by company name", accountId = result.value.Id);
            return result.value.Id;
        }
        
        // Create new account with company name only if rule is company
        if accountAssociationRule == "company" {
            SalesforceAccount newAccount = {
                Name: companyName,
                Description: "Created from Shopify customer"
            };
            
            salesforce:CreationResponse accountResponse = check salesforceClient->create(sObjectName = "Account", sObject = newAccount);
            
            if accountResponse.success {
                log:printInfo("Created new account", accountId = accountResponse.id);
                return accountResponse.id;
            }
        }
    }
    
    // Try to find account by email domain
    if accountAssociationRule == "domain" && email is string {
        string? domain = extractDomainFromEmail(email);
        if domain is string {
            string escapedDomain = escapeSoqlString(domain);
            string soqlQuery = string `SELECT Id, Name, Website FROM Account WHERE Website LIKE '%${escapedDomain}%' LIMIT 1`;
            stream<AccountQueryResult, error?> resultStream = check salesforceClient->query(soql = soqlQuery);
            
            record {|AccountQueryResult value;|}? result = check resultStream.next();
            check resultStream.close();
            
            if result is record {|AccountQueryResult value;|} {
                log:printInfo("Found existing account by domain", accountId = result.value.Id);
                return result.value.Id;
            }
        }
    }
    
    return ();
}

// Create or update Salesforce contact from Shopify customer
public function createOrUpdateSalesforceContact(shopify:CustomerEvent customerEvent) returns error? {
    string? email = customerEvent?.email;
    
    // Duplicate check by email (if enabled)
    if enableDuplicateCheck && email is string && email.trim() != "" {
        ContactQueryResult? existingContact = check findContactByEmail(email);
        
        if existingContact is ContactQueryResult {
            string existingContactId = existingContact.Id;
            log:printInfo("Contact already exists, updating", contactId = existingContactId, email = email);
            
            // Find or create associated account
            string? accountId = check findOrCreateAccount(customerEvent);
            
            // Map Shopify customer to Salesforce contact for update
            SalesforceContact contactUpdate = mapShopifyCustomerToSalesforceContact(customerEvent, accountId = accountId);
            
            // Update existing contact
            error? updateResult = salesforceClient->update(sObjectName = "Contact", id = existingContactId, sObject = contactUpdate);
            
            if updateResult is error {
                log:printError("Failed to update Salesforce contact", 'error = updateResult, contactId = existingContactId);
                return updateResult;
            }
            
            // Add Shopify tag to contact
            error? tagResult = addShopifyTagToContact(existingContactId);
            if tagResult is error {
                log:printWarn("Failed to tag contact, but contact was updated", 'error = tagResult);
            }
            
            log:printInfo("Successfully updated Salesforce contact", 
                contactId = existingContactId,
                accountId = accountId ?: "None",
                origin = "Shopify"
            );
            return;
        }
    }
    
    // Find or create associated account
    string? accountId = check findOrCreateAccount(customerEvent);
    
    // Map Shopify customer to Salesforce contact with account association
    SalesforceContact contact = mapShopifyCustomerToSalesforceContact(customerEvent, accountId = accountId);
    
    // Create contact in Salesforce
    salesforce:CreationResponse response = check salesforceClient->create(sObjectName = "Contact", sObject = contact);
    
    if response.success {
        // Add Shopify tag to contact
        error? tagResult = addShopifyTagToContact(response.id);
        if tagResult is error {
            log:printWarn("Failed to tag contact, but contact was created", 'error = tagResult);
        }
        
        log:printInfo("Successfully created Salesforce contact", 
            contactId = response.id, 
            accountId = accountId ?: "None",
            leadSource = defaultLeadSource,
            origin = "Shopify"
        );
    } else {
        log:printError("Failed to create Salesforce contact", errors = response.errors);
    }
}
