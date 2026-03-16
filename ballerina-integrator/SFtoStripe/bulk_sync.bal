import ballerina/log;

// Bulk sync all Accounts from Salesforce to Stripe
public function bulkSyncAccountsToStripe() returns error? {
    log:printInfo("Starting bulk sync of Accounts from Salesforce to Stripe");

    // Try with Email__c field first, fallback to query without it if field doesn't exist
    string soqlQueryWithEmail = "SELECT Id, Name, Email__c, Phone, BillingStreet, BillingCity, BillingState, " +
                                "BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState, " +
                                "ShippingPostalCode, ShippingCountry, Description, Stripe_Customer_Id__c FROM Account";
    string soqlQueryWithoutEmail = "SELECT Id, Name, Phone, BillingStreet, BillingCity, BillingState, " +
                                   "BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState, " +
                                   "ShippingPostalCode, ShippingCountry, Description, Stripe_Customer_Id__c FROM Account";

    // Execute query - try with email first, fallback if field doesn't exist
    stream<SalesforceAccount, error?>|error accountStreamResult = salesforceClient->query(soqlQueryWithEmail);
    stream<SalesforceAccount, error?> accountStream;
    if accountStreamResult is error {
        string errorMsg = accountStreamResult.message();
        if errorMsg.includes("Email__c") || errorMsg.includes("No such column") {
            log:printInfo("Email__c field not found, querying without it");
            accountStream = check salesforceClient->query(soqlQueryWithoutEmail);
        } else {
            return accountStreamResult;
        }
    } else {
        accountStream = accountStreamResult;
    }

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
                       "MailingState, MailingPostalCode, MailingCountry, OtherStreet, OtherCity, " +
                       "OtherState, OtherPostalCode, OtherCountry, Description, " +
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
}