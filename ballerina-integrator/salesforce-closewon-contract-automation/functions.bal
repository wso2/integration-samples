import ballerina/log;

// Get opportunity details from Salesforce
function getOpportunity(string opportunityId) returns Opportunity|error {
    Opportunity opportunity = check salesforceClient->getById("Opportunity", opportunityId, Opportunity);
    return opportunity;
}

// Get contact by role from opportunity
function getContactByRole(string opportunityId, SignerRole role) returns Contact|error {
    // Query for OpportunityContactRole
    string soqlQuery = string `SELECT Id, OpportunityId, ContactId, Role FROM OpportunityContactRole 
                               WHERE OpportunityId = '${opportunityId}' 
                               AND Role = '${role}'
                               LIMIT 1`;
    
    stream<OpportunityContactRole, error?> roleStream = check salesforceClient->query(soqlQuery, OpportunityContactRole);
    
    OpportunityContactRole[] roles = check from OpportunityContactRole roleRecord in roleStream
        select roleRecord;
    
    if roles.length() == 0 {
        return error(string `No contact found with role: ${role}`);
    }
    
    OpportunityContactRole contactRole = roles[0];
    string contactId = contactRole.ContactId;
    
    // Get contact details
    Contact contact = check salesforceClient->getById("Contact", contactId, Contact);
    return contact;
}

// Get primary contact from opportunity
function getPrimaryContact(string opportunityId) returns Contact|error {
    // Query for primary contact role
    string soqlQuery = string `SELECT Id, OpportunityId, ContactId, IsPrimary FROM OpportunityContactRole 
                               WHERE OpportunityId = '${opportunityId}' 
                               AND IsPrimary = true
                               LIMIT 1`;
    
    stream<OpportunityContactRole, error?> roleStream = check salesforceClient->query(soqlQuery, OpportunityContactRole);
    
    OpportunityContactRole[] roles = check from OpportunityContactRole roleRecord in roleStream
        select roleRecord;
    
    if roles.length() == 0 {
        return error("No primary contact found for opportunity");
    }
    
    OpportunityContactRole contactRole = roles[0];
    string contactId = contactRole.ContactId;
    
    // Get contact details
    Contact contact = check salesforceClient->getById("Contact", contactId, Contact);
    return contact;
}

// Select appropriate template based on opportunity
function selectTemplate(Opportunity opportunity) returns TemplateConfig {
    // Check if there are configured templates
    foreach TemplateConfig templateConfig in templateConfigs {
        string? productType = templateConfig.productType;
        string? dealType = templateConfig.dealType;
        string? oppType = opportunity.Type;
        
        // Match by product type or deal type
        if productType is string && oppType is string && oppType == productType {
            return templateConfig;
        }
        
        if dealType is string && oppType is string && oppType == dealType {
            return templateConfig;
        }
    }
    
    // Return default template
    return {
        templateId: defaultTemplateId,
        expirationDays: expirationReminderDays
    };
}

// Note: buildTemplateFields function moved to automation.bal

// Get opportunity field value by field name
function getOpportunityFieldValue(Opportunity opportunity, string fieldName) returns string|error {
    match fieldName {
        "Name" => {
            return opportunity.Name;
        }
        "Amount" => {
            decimal? amount = opportunity.Amount;
            if amount is decimal {
                return amount.toString();
            }
            return "";
        }
        "CloseDate" => {
            string? closeDate = opportunity.CloseDate;
            if closeDate is string {
                return closeDate;
            }
            return "";
        }
        "Id" => {
            return opportunity.Id;
        }
        "StageName" => {
            return opportunity.StageName;
        }
        "Type" => {
            string? oppType = opportunity.Type;
            if oppType is string {
                return oppType;
            }
            return "";
        }
        _ => {
            return error(string `Unknown opportunity field: ${fieldName}. Valid fields are: Name, Amount, CloseDate, Id, StageName, Type`);
        }
    }
}

// Check if envelope marker exists for this opportunity
function checkEnvelopeMarker(string opportunityId) returns boolean|error {
    // Query for a custom field that stores envelope ID or processing marker
    // This assumes you have a custom field like DocuSign_Envelope_Id__c on Opportunity
    // If the field doesn't exist, this will return false
    
    string soqlQuery = string `SELECT Id, StageName FROM Opportunity 
                               WHERE Id = '${opportunityId}' 
                               LIMIT 1`;
    
    stream<record {string Id; string StageName;}, error?> oppStream = check salesforceClient->query(soqlQuery);
    
    record {string Id; string StageName;}[] opportunities = check from record {string Id; string StageName;} opp in oppStream
        select opp;
    
    if opportunities.length() == 0 {
        return false;
    }
    
    record {string Id; string StageName;} opp = opportunities[0];
    
    // Check if stage indicates envelope was already sent
    if opp.StageName == contractSentStage {
        return true;
    }
    
    // Additional check: Query for any existing DocuSign envelope records
    // This could be a custom object or integration log
    // For now, we rely on stage as the marker
    
    return false;
}

// Update Salesforce opportunity stage with envelope ID
function updateOpportunityStage(string opportunityId, string stageName, string? envelopeId = ()) returns error? {
    
    // Build update payload
    map<json> updatePayload = {
        "StageName": stageName
    };
    
    // Add envelope ID to description or custom field if provided
    if envelopeId is string {
        // Store envelope ID in Description field as a marker
        // In production, use a custom field like DocuSign_Envelope_Id__c
        string envelopeMarker = string `[DocuSign Envelope: ${envelopeId}]`;
        updatePayload["Description"] = envelopeMarker;
        log:printInfo(string `Storing envelope ID ${envelopeId} for opportunity ${opportunityId}`);
    }
    
    // Update opportunity using Salesforce REST API
    error? updateResult = salesforceClient->update("Opportunity", opportunityId, updatePayload);
    
    if updateResult is error {
        log:printError(string `Failed to update opportunity ${opportunityId}: ${updateResult.message()}`);
        // Log the error but don't fail the entire process if Salesforce update fails
        // The envelope was already sent successfully
        log:printWarn("Envelope was sent successfully but Salesforce update failed");
        return updateResult;
    }
    
    log:printInfo(string `Successfully updated opportunity ${opportunityId} stage to ${stageName}`);
}

// Check if opportunity meets criteria
function meetsDispatchCriteria(Opportunity opportunity) returns boolean {
    // Check if stage is Closed Won
    if opportunity.StageName != "Closed Won" {
        return false;
    }
    
    // Check minimum deal value
    decimal? amount = opportunity.Amount;
    if amount is () {
        log:printWarn(string `Opportunity ${opportunity.Id} has no amount specified`);
        return false;
    }
    
    if amount < minimumDealValue {
        log:printInfo(string `Opportunity ${opportunity.Id} amount ${amount} is below minimum threshold ${minimumDealValue}`);
        return false;
    }
    
    return true;
}
