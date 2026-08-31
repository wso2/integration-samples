import ballerina/log;
import ballerinax/salesforce;

// Salesforce Listener Configuration
// NOTE: Before running, ensure Change Data Capture is enabled in Salesforce:
// Setup → Change Data Capture → Select Account and Contact → Save
// Using OAuth2 refresh token auth (avoids SOAP username/password/security token requirement)
listener salesforce:Listener changeEventListener = new ({
    auth: {
        refreshUrl: salesforceConfig.refreshUrl,
        refreshToken: salesforceConfig.refreshToken,
        clientId: salesforceConfig.clientId,
        clientSecret: salesforceConfig.clientSecret
    },
    baseUrl: salesforceConfig.baseUrl
});

// Salesforce Change Event Service
// Channel name is required by the salesforce:Listener.
// /data/ChangeEvents subscribes to all CDC-enabled objects (Account, Contact, etc.)
service "/data/ChangeEvents" on changeEventListener {

    // Handle Create Events
    remote function onCreate(salesforce:EventData eventData) returns error? {
        log:printInfo("Received create event from Salesforce");

        // Determine object type from event metadata
        string entityType = eventData.metadata?.entityName ?: "";
        log:printInfo("[onCreate] entityType=" + entityType + " sourceObject=" + syncConfig.sourceObject);

        // CDC changedData does not include Id — inject it from metadata.recordId
        string recordId = eventData.metadata?.recordId ?: "";
        map<json> data = eventData.changedData;
        data["Id"] = recordId;

        // Route to appropriate handler based on entity type
        if entityType == "Account" && (syncConfig.sourceObject == ACCOUNT || syncConfig.sourceObject == BOTH) {
            // Try to fetch full Account record to ensure we have all fields
            SalesforceAccount account;
            
            string baseFields = "Id, Name, Phone, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Description, Stripe_Customer_Id__c";
            string soqlQueryFull = string `SELECT ${baseFields}, Email__c FROM Account WHERE Id = '${recordId}'`;
            string soqlQueryMinimal = string `SELECT ${baseFields} FROM Account WHERE Id = '${recordId}'`;
            
            stream<SalesforceAccount, error?>|error queryResultOrError = salesforceClient->query(soqlQueryFull);
            stream<SalesforceAccount, error?> queryResult;
            if queryResultOrError is error {
                string errorMsg = queryResultOrError.message();
                if errorMsg.includes("Email__c") {
                    log:printInfo("[onCreate] Email__c field not found, falling back to minimal query");
                    stream<SalesforceAccount, error?>|error minimalResult = salesforceClient->query(soqlQueryMinimal);
                    if minimalResult is error {
                        log:printError("[onCreate] SOQL query failed", 'error = minimalResult, recordId = recordId);
                        return;
                    }
                    queryResult = minimalResult;
                } else {
                    log:printError("[onCreate] SOQL query failed", 'error = queryResultOrError, recordId = recordId);
                    return;
                }
            } else {
                queryResult = queryResultOrError;
            }
            
            record {|SalesforceAccount value;|}? queryRecord = check queryResult.next();
            if queryRecord is record {|SalesforceAccount value;|} {
                account = queryRecord.value;
                log:printInfo("[onCreate] Fetched full Account record", accountId = account?.Id);
            } else {
                // Fallback to CDC data if query returns nothing
                log:printWarn("[onCreate] SOQL query returned no results, using CDC data", recordId = recordId);
                SalesforceAccount|error cdcAccount = data.cloneWithType();
                if cdcAccount is error {
                    log:printError("[onCreate] Failed to parse Account data", 'error = cdcAccount, recordId = recordId);
                    return;
                }
                account = cdcAccount;
            }
            
            error? result = syncAccountToStripe(account);
            if result is error {
                log:printError("[onCreate] Failed to sync Account to Stripe", 'error = result, accountId = account?.Id);
            }
        } else if entityType == "Contact" && (syncConfig.sourceObject == CONTACT || syncConfig.sourceObject == BOTH) {
            // CDC changedData may not include FirstName/LastName on create (only Name)
            // Fetch full record to ensure we have all fields
            SalesforceContact contact;
            string soqlQuery = string `SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Description, Stripe_Customer_Id__c FROM Contact WHERE Id = '${recordId}'`;
            stream<SalesforceContact, error?> queryResult = check salesforceClient->query(soqlQuery);
            record {|SalesforceContact value;|}? queryRecord = check queryResult.next();
            if queryRecord is record {|SalesforceContact value;|} {
                contact = queryRecord.value;
                log:printInfo("[onCreate] Fetched full Contact record", contactId = contact?.Id);
            } else {
                // Fallback to CDC data if query returns nothing
                log:printWarn("[onCreate] SOQL query returned no results, using CDC data", recordId = recordId);
                SalesforceContact|error cdcContact = data.cloneWithType();
                if cdcContact is error {
                    log:printError("[onCreate] Failed to parse Contact data", 'error = cdcContact, recordId = recordId);
                    return;
                }
                contact = cdcContact;
            }
            log:printInfo("[onCreate] Contact parsed", contactId = contact?.Id);
            error? result = syncContactToStripe(contact);
            if result is error {
                log:printError("[onCreate] Failed to sync Contact to Stripe", 'error = result, contactId = contact?.Id);
            }
        } else {
            log:printInfo("[onCreate] No handler for entityType='" + entityType + "' sourceObject='" + syncConfig.sourceObject + "'");
        }
    }

    // Handle Update Events
    remote function onUpdate(salesforce:EventData eventData) returns error? {
        log:printInfo("Received update event from Salesforce");

        // Determine object type from event metadata
        string entityType = eventData.metadata?.entityName ?: "";
        string recordId = eventData.metadata?.recordId ?: "";
        log:printInfo("[onUpdate] entityType=" + entityType + " recordId=" + recordId + " sourceObject=" + syncConfig.sourceObject);

        // Skip writeback-triggered update events (only Stripe_Customer_Id__c changed)
        map<json> changedFields = eventData.changedData;
        
        log:printInfo("[onUpdate] changedData keys BEFORE any filtering: " + changedFields.keys().toString());

        // Detect if this is actually a delete event mislabelled as update
        json changeTypeVal = changedFields["ChangeEventHeader"] is map<json>
            ? ((<map<json>>changedFields["ChangeEventHeader"])["changeType"] ?: "")
            : "";
        log:printInfo("[onUpdate] changeType from ChangeEventHeader: " + changeTypeVal.toString());
        
        // Filter out system fields that are always present in CDC events
        map<json> filteredFields = {};
        foreach var [key, value] in changedFields.entries() {
            if key != "ChangeEventHeader" && key != "LastModifiedDate" {
                filteredFields[key] = value;
            }
        }
        
        // If only Stripe_Customer_Id__c was changed (after filtering system fields), skip processing
        if filteredFields.length() == 1 && filteredFields.hasKey("Stripe_Customer_Id__c") {
            log:printInfo("[onUpdate] Skipping writeback-triggered update (Stripe_Customer_Id__c changed)");
            return;
        }
        
        // If no meaningful fields changed (empty after filtering), skip processing
        if filteredFields.length() == 0 {
            log:printInfo("[onUpdate] No meaningful fields changed, skipping update");
            return;
        }

        // CDC changedData does not include Id — inject it from metadata.recordId
        map<json> data = changedFields;
        data["Id"] = recordId;

        log:printInfo("[onUpdate] changedData keys: " + data.keys().toString());

        // Route to appropriate handler based on entity type
        if entityType == "Account" && (syncConfig.sourceObject == ACCOUNT || syncConfig.sourceObject == BOTH) {
            // CDC changedData only contains changed fields - fetch full record to get all fields including Stripe_Customer_Id__c
            SalesforceAccount account;
            
            string baseFields = "Id, Name, Phone, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Description, Stripe_Customer_Id__c";
            string soqlQueryFull = string `SELECT ${baseFields}, Email__c FROM Account WHERE Id = '${recordId}'`;
            string soqlQueryMinimal = string `SELECT ${baseFields} FROM Account WHERE Id = '${recordId}'`;
            
            stream<SalesforceAccount, error?>|error queryResultOrError = salesforceClient->query(soqlQueryFull);
            stream<SalesforceAccount, error?> queryResult;
            if queryResultOrError is error {
                string errorMsg = queryResultOrError.message();
                if errorMsg.includes("Email__c") {
                    log:printInfo("[onUpdate] Email__c field not found, falling back to minimal query");
                    stream<SalesforceAccount, error?>|error minimalResult = salesforceClient->query(soqlQueryMinimal);
                    if minimalResult is error {
                        log:printError("[onUpdate] SOQL query failed, cannot sync without full record", 'error = minimalResult, recordId = recordId);
                        return;
                    }
                    queryResult = minimalResult;
                } else {
                    log:printError("[onUpdate] SOQL query failed, cannot sync without full record", 'error = queryResultOrError, recordId = recordId);
                    return;
                }
            } else {
                queryResult = queryResultOrError;
            }
            
            record {|SalesforceAccount value;|}|error? queryRecord = queryResult.next();
            if queryRecord is error {
                log:printError("[onUpdate] Failed to read query result, cannot sync without full record", 'error = queryRecord, recordId = recordId);
                return;
            } else if queryRecord is record {|SalesforceAccount value;|} {
                account = queryRecord.value;
                log:printInfo("[onUpdate] Fetched full Account record", accountId = account?.Id);
            } else {
                // Query returned nothing - record may have been deleted
                log:printWarn("[onUpdate] SOQL query returned no results, cannot sync without full record", recordId = recordId);
                return;
            }
            string? stripeCustomerId = account["Stripe_Customer_Id__c"] is string ? <string>account["Stripe_Customer_Id__c"] : ();
            log:printInfo("[onUpdate] Account parsed", accountId = account?.Id, stripeCustomerId = stripeCustomerId);
            error? result = syncAccountToStripe(account, true);
            if result is error {
                log:printError("[onUpdate] Failed to sync Account to Stripe", 'error = result, accountId = account?.Id);
            }
        } else if entityType == "Contact" && (syncConfig.sourceObject == CONTACT || syncConfig.sourceObject == BOTH) {
            // CDC changedData only contains changed fields - fetch full record to get FirstName/LastName
            SalesforceContact contact;
            string soqlQuery = string `SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Description, Stripe_Customer_Id__c FROM Contact WHERE Id = '${recordId}'`;
            stream<SalesforceContact, error?>|error queryResult = salesforceClient->query(soqlQuery);
            if queryResult is error {
                log:printError("[onUpdate] SOQL query failed, cannot sync without full record", 'error = queryResult, recordId = recordId);
                return;
            } else {
                record {|SalesforceContact value;|}|error? queryRecord = queryResult.next();
                if queryRecord is error {
                    log:printError("[onUpdate] Failed to read query result, cannot sync without full record", 'error = queryRecord, recordId = recordId);
                    return;
                } else if queryRecord is record {|SalesforceContact value;|} {
                    contact = queryRecord.value;
                    log:printInfo("[onUpdate] Fetched full Contact record", contactId = contact?.Id);
                } else {
                    // Query returned nothing - record may have been deleted
                    log:printWarn("[onUpdate] SOQL query returned no results, cannot sync without full record", recordId = recordId);
                    return;
                }
            }
            log:printInfo("[onUpdate] Contact parsed", contactId = contact?.Id);
            error? result = syncContactToStripe(contact, true);
            if result is error {
                log:printError("[onUpdate] Failed to sync Contact to Stripe", 'error = result, contactId = contact?.Id);
            }
        } else {
            log:printInfo("[onUpdate] No handler for entityType='" + entityType + "' sourceObject='" + syncConfig.sourceObject + "'");
        }
    }

    // Handle Delete Events
    remote function onDelete(salesforce:EventData eventData) returns error? {
        log:printInfo("Received delete event from Salesforce");

        // Determine object type from event metadata
        string entityType = eventData.metadata?.entityName ?: "";
        string recordId = eventData.metadata?.recordId ?: "";

        if recordId == "" {
            log:printWarn("[onDelete] No recordId in event metadata, skipping");
            return;
        }

        log:printInfo("[onDelete] Processing delete", entityType = entityType, recordId = recordId);

        // Check if delete handling is enabled
        if !syncConfig.deleteStripeCustomerOnSalesforceDelete {
            log:printInfo("[onDelete] Delete handling disabled, skipping Stripe customer deletion", recordId = recordId);
            return;
        }

        // Record is already deleted in SF — find Stripe customer by salesforce_id metadata
        if entityType == "Account" && (syncConfig.sourceObject == ACCOUNT || syncConfig.sourceObject == BOTH) {
            error? result = deleteStripeCustomerBySalesforceId(recordId);
            if result is error {
                log:printError("Failed to handle Account deletion", accountId = recordId, 'error = result);
            }
        } else if entityType == "Contact" && (syncConfig.sourceObject == CONTACT || syncConfig.sourceObject == BOTH) {
            error? result = deleteStripeCustomerBySalesforceId(recordId);
            if result is error {
                log:printError("Failed to handle Contact deletion", contactId = recordId, 'error = result);
            }
        }
    }

    // Handle Restore Events
    remote function onRestore(salesforce:EventData eventData) returns error? {
        log:printInfo("Received restore event from Salesforce");

        // Determine object type from event metadata
        string entityType = eventData.metadata?.entityName ?: "";

        // CDC changedData does not include Id — inject it from metadata.recordId
        string recordId = eventData.metadata?.recordId ?: "";
        map<json> data = eventData.changedData;
        data["Id"] = recordId;

        // Route to appropriate handler based on entity type
        if entityType == "Account" && (syncConfig.sourceObject == ACCOUNT || syncConfig.sourceObject == BOTH) {
            SalesforceAccount account = check data.cloneWithType();
            check syncAccountToStripe(account);
        } else if entityType == "Contact" && (syncConfig.sourceObject == CONTACT || syncConfig.sourceObject == BOTH) {
            SalesforceContact contact = check data.cloneWithType();
            check syncContactToStripe(contact);
        }
    }
}