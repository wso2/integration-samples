import ballerina/log;

// Bulk sync all Accounts from Salesforce to Stripe
public function bulkSyncAccountsToStripe() returns error? {
    log:printInfo("Starting bulk sync of Accounts from Salesforce to Stripe");

    // Query only Id - all other fields are optional and accessed dynamically
    // We query common fields to populate the record, but if they don't exist, we just get Id
    string soqlQuery = "SELECT Id FROM Account";

    // Execute query
    stream<SalesforceAccount, error?> accountStream = check salesforceClient->query(soqlQuery);

    int successCount = 0;
    int errorCount = 0;

    // Process each account
    check from SalesforceAccount account in accountStream
        do {
            // Fetch full record for each account to get all available fields
            string accountId = account?.Id ?: "";
            if accountId != "" {
                string detailQuery = "SELECT Id, Name, Email__c, Phone, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Description, Stripe_Customer_Id__c FROM Account WHERE Id = '" + accountId + "'";
                stream<SalesforceAccount, error?>|error detailResult = salesforceClient->query(detailQuery);
                
                SalesforceAccount fullAccount = account;
                if detailResult is stream<SalesforceAccount, error?> {
                    record {|SalesforceAccount value;|}? detailRecord = check detailResult.next();
                    if detailRecord is record {|SalesforceAccount value;|} {
                        fullAccount = detailRecord.value;
                    }
                }
                
                error? result = syncAccountToStripe(fullAccount);
                if result is error {
                    log:printError("Failed to sync Account", accountId = fullAccount?.Id, 'error = result);
                    errorCount += 1;
                } else {
                    successCount += 1;
                }
            }
        };

    log:printInfo("Bulk sync of Accounts completed", successCount = successCount, errorCount = errorCount);
}

// Bulk sync all Contacts from Salesforce to Stripe
public function bulkSyncContactsToStripe() returns error? {
    log:printInfo("Starting bulk sync of Contacts from Salesforce to Stripe");

    // Query only Id - all other fields are optional and accessed dynamically
    string soqlQuery = "SELECT Id FROM Contact";

    // Execute query
    stream<SalesforceContact, error?> contactStream = check salesforceClient->query(soqlQuery);

    int successCount = 0;
    int errorCount = 0;

    // Process each contact
    check from SalesforceContact contact in contactStream
        do {
            // Fetch full record for each contact to get all available fields
            string contactId = contact?.Id ?: "";
            if contactId != "" {
                string detailQuery = "SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Description, Stripe_Customer_Id__c FROM Contact WHERE Id = '" + contactId + "'";
                stream<SalesforceContact, error?>|error detailResult = salesforceClient->query(detailQuery);
                
                SalesforceContact fullContact = contact;
                if detailResult is stream<SalesforceContact, error?> {
                    record {|SalesforceContact value;|}? detailRecord = check detailResult.next();
                    if detailRecord is record {|SalesforceContact value;|} {
                        fullContact = detailRecord.value;
                    }
                }
                
                error? result = syncContactToStripe(fullContact);
                if result is error {
                    log:printError("Failed to sync Contact", contactId = fullContact?.Id, 'error = result);
                    errorCount += 1;
                } else {
                    successCount += 1;
                }
            }
        };

    log:printInfo("Bulk sync of Contacts completed", successCount = successCount, errorCount = errorCount);
}

// Main bulk sync function based on configuration
public function bulkSync() returns error? {
    log:printInfo("Starting bulk sync based on configuration", sourceObject = syncConfig.sourceObject);

    if syncConfig.sourceObject == ACCOUNT || syncConfig.sourceObject == BOTH {
        check bulkSyncAccountsToStripe();
    }

    if syncConfig.sourceObject == CONTACT || syncConfig.sourceObject == BOTH {
        check bulkSyncContactsToStripe();
    }
}