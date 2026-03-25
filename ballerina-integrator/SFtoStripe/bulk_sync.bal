import ballerina/log;

// Bulk sync all Accounts from Salesforce to Stripe
public function bulkSyncAccountsToStripe() returns error? {
    log:printInfo("Starting bulk sync of Accounts from Salesforce to Stripe");

    // Try with all optional fields first, fallback if they don't exist
    string soqlQueryFull = "SELECT Id, Name, Email__c, Phone, ShippingStreet, ShippingCity, ShippingState, " +
                           "ShippingPostalCode, ShippingCountry, Description, Stripe_Customer_Id__c, RecordTypeId, AccountStatus__c FROM Account";
    string soqlQueryNoEmail = "SELECT Id, Name, Phone, ShippingStreet, ShippingCity, ShippingState, " +
                              "ShippingPostalCode, ShippingCountry, Description, Stripe_Customer_Id__c, RecordTypeId, AccountStatus__c FROM Account";
    string soqlQueryNoStatus = "SELECT Id, Name, Email__c, Phone, ShippingStreet, ShippingCity, ShippingState, " +
                               "ShippingPostalCode, ShippingCountry, Description, Stripe_Customer_Id__c, RecordTypeId FROM Account";
    string soqlQueryMinimal = "SELECT Id, Name, Phone, ShippingStreet, ShippingCity, ShippingState, " +
                              "ShippingPostalCode, ShippingCountry, Description, Stripe_Customer_Id__c, RecordTypeId FROM Account";

    // Execute query with fallback logic
    stream<SalesforceAccount, error?>|error accountStreamResult = salesforceClient->query(soqlQueryFull);
    stream<SalesforceAccount, error?> accountStream;
    if accountStreamResult is error {
        string errorMsg = accountStreamResult.message();
        if errorMsg.includes("Email__c") {
            log:printInfo("Email__c field not found, querying without it");
            stream<SalesforceAccount, error?>|error fallbackResult = salesforceClient->query(soqlQueryNoEmail);
            if fallbackResult is error {
                return fallbackResult;
            }
            accountStream = fallbackResult;
        } else if errorMsg.includes("AccountStatus__c") {
            log:printInfo("AccountStatus__c field not found, querying without it");
            stream<SalesforceAccount, error?>|error fallbackResult = salesforceClient->query(soqlQueryNoStatus);
            if fallbackResult is error {
                string fallbackErrorMsg = fallbackResult.message();
                if fallbackErrorMsg.includes("Email__c") {
                    log:printInfo("Email__c also not found, using minimal query");
                    accountStream = check salesforceClient->query(soqlQueryMinimal);
                } else {
                    return fallbackResult;
                }
            } else {
                accountStream = fallbackResult;
            }
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
}