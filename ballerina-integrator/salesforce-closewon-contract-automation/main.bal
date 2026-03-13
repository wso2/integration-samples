import ballerinax/salesforce;
import ballerina/log;

// Salesforce Listener Service for Opportunity Changes
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
        salesforce:ChangeEventMetadata? metadata = eventData.metadata;
        if metadata is () {
            log:printError("No metadata found in Salesforce ChangeEvent");
            return error("Invalid Salesforce ChangeEvent: missing metadata");
        }
        
        string opportunityId = metadata.recordId ?: "";
        if opportunityId.length() == 0 {
            log:printError("No recordId found in Salesforce ChangeEvent metadata");
            return error("Invalid Salesforce ChangeEvent: missing recordId");
        }
        
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
