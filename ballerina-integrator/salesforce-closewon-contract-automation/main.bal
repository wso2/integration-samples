import ballerinax/salesforce;
import ballerina/log;

// Salesforce Listener Service for Change Events
// The service name MUST be the exact Salesforce channel path you want to listen to
// Options:
//   - "/data/ChangeEvents" - All object changes (default)
//   - "/data/OpportunityChangeEvent" - Opportunity changes only
//   - "/data/AccountChangeEvent" - Account changes only
//   - Custom channels as configured in Salesforce Change Data Capture
// Note: The channel must be enabled in Salesforce Setup > Change Data Capture
service "/data/ChangeEvents" on salesforceListener {
    
    // Handle opportunity creation events
    remote function onCreate(salesforce:EventData eventData) returns error? {
        log:printInfo("Received onCreate event from Salesforce");
        // Contract dispatch is only for Closed Won opportunities
        // onCreate events are typically not Closed Won, so we skip
    }
    
    // Handle opportunity update events
    remote function onUpdate(salesforce:EventData eventData) returns error? {
        log:printInfo("Received onUpdate event from Salesforce");
        
        // Extract opportunity ID from event data
        // Salesforce Change Events have the structure: {ChangeEventHeader: {recordIds: ["id1", "id2"]}, ...fields}
        map<json> payload = eventData.changedData;
        
        // Try to get the entity ID from ChangeEventHeader.recordIds
        json changeEventHeaderJson = payload["ChangeEventHeader"];
        
        if changeEventHeaderJson is () {
            log:printError("No ChangeEventHeader found in event data");
            log:printDebug(string `Event payload: ${payload.toString()}`);
            return;
        }
        
        map<json> changeEventHeader = check changeEventHeaderJson.ensureType();
        json recordIdsJson = changeEventHeader["recordIds"];
        
        if recordIdsJson is () {
            log:printError("No recordIds found in ChangeEventHeader");
            return;
        }
        
        json[] recordIds = check recordIdsJson.ensureType();
        
        if recordIds.length() == 0 {
            log:printError("recordIds array is empty");
            return;
        }
        
        // Get the first record ID (typically only one for single record updates)
        string opportunityId = recordIds[0].toString();
        
        log:printInfo(string `Processing opportunity ID: ${opportunityId}`);
        
        // Process opportunity for contract dispatch
        error? result = processOpportunityForContract(opportunityId);
        
        if result is error {
            log:printError(string `Error processing opportunity ${opportunityId}: ${result.message()}`);
            return result;
        }
    }
    
    // Handle opportunity delete events
    remote function onDelete(salesforce:EventData eventData) returns error? {
        log:printInfo("Received onDelete event from Salesforce");
        // No action needed for delete events
    }
    
    // Handle opportunity restore events
    remote function onRestore(salesforce:EventData eventData) returns error? {
        log:printInfo("Received onRestore event from Salesforce");
        // No action needed for restore events
    }
}
