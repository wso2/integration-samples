// Data mapping utilities for transforming Salesforce data to DocuSign format

import ballerina/log;

// Map Salesforce opportunity to DocuSign envelope subject
public function mapEnvelopeSubject(Opportunity opportunity) returns string {
    return string `Contract for ${opportunity.Name}`;
}

// Map Salesforce contact to DocuSign signer
public function mapContactToSigner(Contact contact, string roleName) returns SignerInfo {
    string signerName = buildContactName(contact);
    
    return {
        email: contact.Email,
        name: signerName,
        roleName: roleName,
        routingOrder: 1
    };
}

// Build full contact name
function buildContactName(Contact contact) returns string {
    string? firstName = contact.FirstName;
    string lastName = contact.LastName;
    
    if firstName is string {
        return string `${firstName} ${lastName}`;
    }
    
    return lastName;
}

// Mask email address for logging to protect PII
function maskEmail(string email) returns string {
    int? atIndex = email.indexOf("@");
    
    if atIndex is () || atIndex < 2 {
        // If no @ found or email is too short, return masked placeholder
        return "***@***";
    }
    
    // Show first 2 characters and domain, mask the rest
    string localPart = email.substring(0, atIndex);
    string domain = email.substring(atIndex);
    
    if localPart.length() <= 2 {
        return string `${localPart}***${domain}`;
    }
    
    string visiblePart = localPart.substring(0, 2);
    return string `${visiblePart}***${domain}`;
}

// Validate opportunity data before processing
public function validateOpportunityData(Opportunity opportunity) returns error? {
    // Validate required fields
    if opportunity.Name.trim() == "" {
        return error("Opportunity name is required");
    }
    
    decimal? amount = opportunity.Amount;
    if amount is () {
        return error("Opportunity amount is required");
    }
    
    if amount < 0d {
        return error("Opportunity amount must be positive");
    }
    
    log:printInfo(string `Validated opportunity ${opportunity.Id}: ${opportunity.Name}`);
}

// Validate contact data before processing
public function validateContactData(Contact contact) returns error? {
    // Validate email
    if contact.Email.trim() == "" {
        return error("Contact email is required");
    }
    
    // Basic email validation
    if !contact.Email.includes("@") {
        return error(string `Invalid email format: ${contact.Email}`);
    }
    
    // Validate name
    if contact.LastName.trim() == "" {
        return error("Contact last name is required");
    }
    
    // Mask email for logging to avoid exposing PII
    string maskedEmail = maskEmail(contact.Email);
    log:printInfo(string `Validated contact ${contact.Id}: ${maskedEmail}`);
}
