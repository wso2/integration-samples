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
        
        // Extract opportunity ID from event metadata
        // The EventData has a metadata field that contains the ChangeEventMetadata
        salesforce:ChangeEventMetadata? metadataValue = eventData.metadata;
        
        if metadataValue is () {
            log:printError("No metadata found in event data");
            return;
        }
        
        // Convert metadata to JSON to access fields
        json metadataJson = metadataValue.toJson();
        
        if metadataJson !is map<json> {
            log:printError("Metadata is not a JSON map");
            return error("Invalid metadata structure");
        }
        
        map<json> metadataMap = metadataJson;
        
        // Log the metadata for debugging
        log:printInfo(string `Event metadata: ${metadataMap.toJsonString()}`);
        
        // Get recordIds from metadata
        json recordIdsJson = metadataMap["recordIds"];
        
        if recordIdsJson is () {
            log:printError("No recordIds found in event metadata");
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
