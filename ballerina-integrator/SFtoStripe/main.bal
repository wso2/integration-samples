import ballerina/log;
import ballerinax/salesforce;

// Salesforce Listener Configuration
// NOTE: Before running, ensure Change Data Capture is enabled in Salesforce:
// Setup → Change Data Capture → Select Account and Contact → Save
// Using OAuth2 refresh token auth (avoids SOAP username/password/security token requirement)
listener salesforce:Listener changeEventListener = new ({
    auth: {
        refreshUrl: salesforceRefreshUrl,
        refreshToken: salesforceRefreshToken,
        clientId: salesforceClientId,
        clientSecret: salesforceClientSecret
    },
    baseUrl: salesforceBaseUrl
});

// Salesforce Change Event Service
// Channel name is required by the salesforce:Listener.
// /data/ChangeEvents subscribes to all CDC-enabled objects (Account, Contact, etc.)
service "/data/ChangeEvents" on changeEventListener {

    // Handle Create Events
    remote function onCreate(salesforce:EventData eventData) returns error? {
        log:printInfo("Received create event from Salesforce");

        // Only process if sync direction allows SF to Stripe
        if syncDirection == STRIPE_TO_SF {
            log:printInfo("Sync direction is Stripe to SF, skipping create event");
            return;
        }

        // Determine object type from event metadata
        string entityType = eventData.metadata?.entityName ?: "";
        log:printInfo("[onCreate] entityType=" + entityType + " sourceObject=" + sourceObject);

        // CDC changedData does not include Id — inject it from metadata.recordId
        string recordId = eventData.metadata?.recordId ?: "";
        map<json> data = eventData.changedData;
        data["Id"] = recordId;

        // Route to appropriate handler based on entity type
        if entityType == "Account" && (sourceObject == ACCOUNT || sourceObject == BOTH) {
            SalesforceAccount|error account = data.cloneWithType();
            if account is error {
                log:printError("[onCreate] Failed to parse Account data", 'error = account, data = data.toString());
                return;
            }
            error? result = syncAccountToStripe(account);
            if result is error {
                log:printError("[onCreate] Failed to sync Account to Stripe", 'error = result, accountId = account?.Id);
            }
        } else if entityType == "Contact" && (sourceObject == CONTACT || sourceObject == BOTH) {
            // CDC changedData may not include FirstName/LastName on create (only Name)
            // Fetch full record to ensure we have all fields
            SalesforceContact contact;
            string soqlQuery = string `SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Description, Stripe_Customer_Id__c FROM Contact WHERE Id = '${recordId}'`;
            stream<SalesforceContact, error?> queryResult = check salesforceClient->query(soqlQuery);
            record {|SalesforceContact value;|}? queryRecord = check queryResult.next();
            if queryRecord is record {|SalesforceContact value;|} {
                contact = queryRecord.value;
                log:printInfo("[onCreate] Fetched full Contact record", contactId = contact?.Id, firstName = contact?.FirstName, lastName = contact?.LastName);
            } else {
                // Fallback to CDC data if query returns nothing
                log:printWarn("[onCreate] SOQL query returned no results, using CDC data", recordId = recordId);
                SalesforceContact|error cdcContact = data.cloneWithType();
                if cdcContact is error {
                    log:printError("[onCreate] Failed to parse Contact data", 'error = cdcContact, data = data.toString());
                    return;
                }
                contact = cdcContact;
            }
            log:printInfo("[onCreate] Contact parsed", contactId = contact?.Id, email = contact?.Email, firstName = contact?.FirstName, lastName = contact?.LastName);
            error? result = syncContactToStripe(contact);
            if result is error {
                log:printError("[onCreate] Failed to sync Contact to Stripe", 'error = result, contactId = contact?.Id);
            }
        } else {
            log:printInfo("[onCreate] No handler for entityType='" + entityType + "' sourceObject='" + sourceObject + "'");
        }
    }

    // Handle Update Events
    remote function onUpdate(salesforce:EventData eventData) returns error? {
        log:printInfo("Received update event from Salesforce");

        // Only process if sync direction allows SF to Stripe
        if syncDirection == STRIPE_TO_SF {
            log:printInfo("Sync direction is Stripe to SF, skipping update event");
            return;
        }

        // Determine object type from event metadata
        string entityType = eventData.metadata?.entityName ?: "";
        string recordId = eventData.metadata?.recordId ?: "";
        log:printInfo("[onUpdate] entityType=" + entityType + " recordId=" + recordId + " sourceObject=" + sourceObject);

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
        if entityType == "Account" && (sourceObject == ACCOUNT || sourceObject == BOTH) {
            // CDC changedData only contains changed fields - fetch full record to get all fields including Stripe_Customer_Id__c
            SalesforceAccount account;
            string soqlQuery = string `SELECT Id, Name, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Description, Stripe_Customer_Id__c FROM Account WHERE Id = '${recordId}'`;
            stream<SalesforceAccount, error?>|error queryResult = salesforceClient->query(soqlQuery);
            if queryResult is error {
                log:printError("[onUpdate] SOQL query failed", 'error = queryResult, recordId = recordId);
                SalesforceAccount|error cdcAccount = data.cloneWithType();
                if cdcAccount is error {
                    log:printError("[onUpdate] Failed to parse Account data", 'error = cdcAccount, data = data.toString());
                    return;
                }
                account = cdcAccount;
            } else {
                record {|SalesforceAccount value;|}|error? queryRecord = queryResult.next();
                if queryRecord is error {
                    log:printError("[onUpdate] Failed to read query result", 'error = queryRecord, recordId = recordId);
                    SalesforceAccount|error cdcAccount = data.cloneWithType();
                    if cdcAccount is error {
                        log:printError("[onUpdate] Failed to parse Account data", 'error = cdcAccount, data = data.toString());
                        return;
                    }
                    account = cdcAccount;
                } else if queryRecord is record {|SalesforceAccount value;|} {
                    account = queryRecord.value;
                    log:printInfo("[onUpdate] Fetched full Account record", accountId = account?.Id, name = account?.Name);
                } else {
                    // Query returned nothing
                    log:printWarn("[onUpdate] SOQL query returned no results, using CDC data", recordId = recordId);
                    SalesforceAccount|error cdcAccount = data.cloneWithType();
                    if cdcAccount is error {
                        log:printError("[onUpdate] Failed to parse Account data", 'error = cdcAccount, data = data.toString());
                        return;
                    }
                    account = cdcAccount;
                }
            }
            log:printInfo("[onUpdate] Account parsed", accountId = account?.Id, name = account?.Name, stripeCustomerId = account?.Stripe_Customer_Id__c);
            error? result = syncAccountToStripe(account, true);
            if result is error {
                log:printError("[onUpdate] Failed to sync Account to Stripe", 'error = result, accountId = account?.Id);
            }
        } else if entityType == "Contact" && (sourceObject == CONTACT || sourceObject == BOTH) {
            // CDC changedData only contains changed fields - fetch full record to get FirstName/LastName
            SalesforceContact contact;
            string soqlQuery = string `SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Description, Stripe_Customer_Id__c FROM Contact WHERE Id = '${recordId}'`;
            stream<SalesforceContact, error?>|error queryResult = salesforceClient->query(soqlQuery);
            if queryResult is error {
                log:printError("[onUpdate] SOQL query failed", 'error = queryResult, recordId = recordId);
                SalesforceContact|error cdcContact = data.cloneWithType();
                if cdcContact is error {
                    log:printError("[onUpdate] Failed to parse Contact data", 'error = cdcContact, data = data.toString());
                    return;
                }
                contact = cdcContact;
            } else {
                record {|SalesforceContact value;|}|error? queryRecord = queryResult.next();
                if queryRecord is error {
                    log:printError("[onUpdate] Failed to read query result", 'error = queryRecord, recordId = recordId);
                    SalesforceContact|error cdcContact = data.cloneWithType();
                    if cdcContact is error {
                        log:printError("[onUpdate] Failed to parse Contact data", 'error = cdcContact, data = data.toString());
                        return;
                    }
                    contact = cdcContact;
                } else if queryRecord is record {|SalesforceContact value;|} {
                    contact = queryRecord.value;
                    log:printInfo("[onUpdate] Fetched full Contact record", contactId = contact?.Id, firstName = contact?.FirstName, lastName = contact?.LastName);
                } else {
                    // Query returned nothing
                    log:printWarn("[onUpdate] SOQL query returned no results, using CDC data", recordId = recordId);
                    SalesforceContact|error cdcContact = data.cloneWithType();
                    if cdcContact is error {
                        log:printError("[onUpdate] Failed to parse Contact data", 'error = cdcContact, data = data.toString());
                        return;
                    }
                    contact = cdcContact;
                }
            }
            log:printInfo("[onUpdate] Contact parsed", contactId = contact?.Id, email = contact?.Email, firstName = contact?.FirstName, lastName = contact?.LastName);
            error? result = syncContactToStripe(contact, true);
            if result is error {
                log:printError("[onUpdate] Failed to sync Contact to Stripe", 'error = result, contactId = contact?.Id);
            }
        } else {
            log:printInfo("[onUpdate] No handler for entityType='" + entityType + "' sourceObject='" + sourceObject + "'");
        }
    }

    // Handle Delete Events
    remote function onDelete(salesforce:EventData eventData) returns error? {
        log:printInfo("Received delete event from Salesforce");
        log:printInfo("[onDelete] RAW changedData: " + eventData.changedData.toString());
        log:printInfo("[onDelete] RAW metadata: entityName=" + (eventData.metadata?.entityName ?: "nil")
            + " recordId=" + (eventData.metadata?.recordId ?: "nil")
            + " changeType=" + (eventData.metadata?.changeType ?: "nil"));

        // Only process if sync direction allows SF to Stripe
        if syncDirection == STRIPE_TO_SF {
            log:printInfo("Sync direction is Stripe to SF, skipping delete event");
            return;
        }

        // Determine object type from event metadata
        string entityType = eventData.metadata?.entityName ?: "";
        string recordId = eventData.metadata?.recordId ?: "";

        if recordId == "" {
            log:printWarn("[onDelete] No recordId in event metadata, skipping");
            return;
        }

        log:printInfo("[onDelete] Processing delete", entityType = entityType, recordId = recordId);

        // Record is already deleted in SF — find Stripe customer by salesforce_id metadata
        if entityType == "Account" && (sourceObject == ACCOUNT || sourceObject == BOTH) {
            error? result = deleteStripeCustomerBySalesforceId(recordId);
            if result is error {
                log:printError("Failed to handle Account deletion", accountId = recordId, 'error = result);
            }
        } else if entityType == "Contact" && (sourceObject == CONTACT || sourceObject == BOTH) {
            error? result = deleteStripeCustomerBySalesforceId(recordId);
            if result is error {
                log:printError("Failed to handle Contact deletion", contactId = recordId, 'error = result);
            }
        }
    }

    // Handle Restore Events
    remote function onRestore(salesforce:EventData eventData) returns error? {
        log:printInfo("Received restore event from Salesforce");

        // Only process if sync direction allows SF to Stripe
        if syncDirection == STRIPE_TO_SF {
            log:printInfo("Sync direction is Stripe to SF, skipping restore event");
            return;
        }

        // Determine object type from event metadata
        string entityType = eventData.metadata?.entityName ?: "";

        // CDC changedData does not include Id — inject it from metadata.recordId
        string recordId = eventData.metadata?.recordId ?: "";
        map<json> data = eventData.changedData;
        data["Id"] = recordId;

        // Route to appropriate handler based on entity type
        if entityType == "Account" && (sourceObject == ACCOUNT || sourceObject == BOTH) {
            SalesforceAccount account = check data.cloneWithType();
            check syncAccountToStripe(account);
        } else if entityType == "Contact" && (sourceObject == CONTACT || sourceObject == BOTH) {
            SalesforceContact contact = check data.cloneWithType();
            check syncContactToStripe(contact);
        }
    }
}