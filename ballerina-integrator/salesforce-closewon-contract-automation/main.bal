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
        
        // Log the full payload for debugging
        log:printInfo(string `Event payload: ${payload.toJsonString()}`);
        
        // Try to get the entity ID from ChangeEventHeader.recordIds
        json changeEventHeaderJson = payload["ChangeEventHeader"];
        
        if changeEventHeaderJson is () {
            log:printError("No ChangeEventHeader found in event data");
            return;
        }
        
        // Type narrow to map<json>
        if changeEventHeaderJson !is map<json> {
            log:printError(string `ChangeEventHeader is not a map, type: ${(typeof changeEventHeaderJson).toString()}`);
            return error("Invalid ChangeEventHeader structure");
        }
        
        map<json> changeEventHeader = changeEventHeaderJson;
        json recordIdsJson = changeEventHeader["recordIds"];
        
        if recordIdsJson is () {
            log:printError("No recordIds found in ChangeEventHeader");
            return;
        }
        
        // Type narrow to json array
        if recordIdsJson !is json[] {
            log:printError(string `recordIds is not an array, type: ${(typeof recordIdsJson).toString()}`);
            return error("Invalid recordIds structure");
        }
        
        json[] recordIds = recordIdsJson;
        
        if recordIds.length() == 0 {
            log:printError("recordIds array is empty");
            return;
        }
        
        // Get the first record ID (typically only one for single record updates)
        json firstRecordId = recordIds[0];
        string opportunityId = firstRecordId.toString();
        
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
