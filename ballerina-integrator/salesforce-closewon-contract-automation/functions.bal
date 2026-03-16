import ballerina/log;

// Get opportunity details from Salesforce
function getOpportunity(string opportunityId) returns Opportunity|error {
    log:printInfo(string `Fetching opportunity details for ID: ${opportunityId}`);
    Opportunity|error opportunityResult = salesforceClient->getById("Opportunity", opportunityId, Opportunity);
    if opportunityResult is error {
        log:printError(string `Salesforce API error: ${opportunityResult.message()}`);
        return opportunityResult;
    }
    return opportunityResult;
}

// Get contact by role from opportunity
function getContactByRole(string opportunityId, SignerRole role) returns Contact|error {
    // Query for OpportunityContactRole
    string soqlQuery = string `SELECT ContactId, Role FROM OpportunityContactRole 
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
    string soqlQuery = string `SELECT ContactId FROM OpportunityContactRole 
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
    foreach TemplateConfig templateConfig in templateSettings.templateConfigs {
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
        templateId: templateSettings.defaultTemplateId,
        expirationDays: businessRulesConfig.expirationReminderDays
    };
}

// Note: buildTemplateFields function moved to automation.bal

// Get opportunity field value by field name
function getOpportunityFieldValue(Opportunity opportunity, string fieldName) returns string {
    match fieldName {
        "Name" => {
            return opportunity.Name;
        }
        "Amount" => {
            decimal? amount = opportunity.Amount;
            if amount is decimal {
                return amount.toString();
            }
        }
        "CloseDate" => {
            string? closeDate = opportunity.CloseDate;
            if closeDate is string {
                return closeDate;
            }
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
        }
    }
    
    return "";
}

// Update Salesforce opportunity stage
function updateOpportunityStage(string opportunityId, string stageName) returns error? {
    // Note: The Salesforce client doesn't have a direct update method
    // We'll log the update for now - in production, you'd use the REST API directly
    log:printInfo(string `Would update opportunity ${opportunityId} stage to ${stageName}`);
    log:printWarn("Opportunity stage update requires additional Salesforce REST API implementation");
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
    
    if amount < businessRulesConfig.minimumDealValue {
        log:printInfo(string `Opportunity ${opportunity.Id} amount ${amount} is below minimum threshold ${businessRulesConfig.minimumDealValue}`);
        return false;
    }
    
    return true;
}
