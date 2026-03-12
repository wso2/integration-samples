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
    
    log:printInfo(string `Validated contact ${contact.Id}: ${contact.Email}`);
}
