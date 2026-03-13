import ballerina/log;

// Bulk sync all Accounts from Salesforce to Stripe
public function bulkSyncAccountsToStripe() returns error? {
    log:printInfo("Starting bulk sync of Accounts from Salesforce to Stripe");

    // Build SOQL query (only include fields that exist in your Salesforce org)
    string soqlQuery = "SELECT Id, Name, Phone, BillingStreet, BillingCity, BillingState, " +
                       "BillingPostalCode, BillingCountry, Description, Stripe_Customer_Id__c FROM Account";

    // Execute query
    stream<SalesforceAccount, error?> accountStream = check salesforceClient->query(soqlQuery);

    int successCount = 0;
    int errorCount = 0;

    // Process each account
    check from SalesforceAccount account in accountStream
        do {
            error? result = syncAccountToStripe(account);
            if result is error {
                log:printError("Failed to sync Account", accountId = account?.Id, 'error = result);
                errorCount += 1;
            } else {
                successCount += 1;
            }
        };

    log:printInfo("Bulk sync of Accounts completed", successCount = successCount, errorCount = errorCount);
}

// Bulk sync all Contacts from Salesforce to Stripe
public function bulkSyncContactsToStripe() returns error? {
    log:printInfo("Starting bulk sync of Contacts from Salesforce to Stripe");

    // Build SOQL query
    string soqlQuery = "SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, MailingCity, " +
                       "MailingState, MailingPostalCode, MailingCountry, Description, " +
                       "Stripe_Customer_Id__c, RecordTypeId FROM Contact";

    // Execute query
    stream<SalesforceContact, error?> contactStream = check salesforceClient->query(soqlQuery);

    int successCount = 0;
    int errorCount = 0;

    // Process each contact
    check from SalesforceContact contact in contactStream
        do {
            error? result = syncContactToStripe(contact);
            if result is error {
                log:printError("Failed to sync Contact", contactId = contact?.Id, 'error = result);
                errorCount += 1;
            } else {
                successCount += 1;
            }
        };

    log:printInfo("Bulk sync of Contacts completed", successCount = successCount, errorCount = errorCount);
}

// Main bulk sync function based on configuration
public function bulkSync() returns error? {
    log:printInfo("Starting bulk sync based on configuration", sourceObject = sourceObject);

    if sourceObject == ACCOUNT || sourceObject == BOTH {
        check bulkSyncAccountsToStripe();
    }

    if sourceObject == CONTACT || sourceObject == BOTH {
        check bulkSyncContactsToStripe();
    }

    log:printInfo("Bulk sync completed successfully");
}