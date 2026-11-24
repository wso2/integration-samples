// Data mapping utilities for transforming Salesforce data to DocuSign format

import ballerina/log;

// Map Salesforce opportunity to DocuSign envelope subject
public function mapEnvelopeSubject(Opportunity opportunity) returns string {
    string? opportunityName = opportunity.Name;
    if opportunityName is string {
        return string `Contract for ${opportunityName}`;
    }
    return "Contract";
}

// Map Salesforce contact to DocuSign signer
public function mapContactToSigner(Contact contact, string roleName) returns SignerInfo|error {
    string signerName = buildContactName(contact);
    
    string? contactEmail = contact.Email;
    if contactEmail is () {
        return error("Contact email is required");
    }
    
    return {
        email: contactEmail,
        name: signerName,
        roleName: roleName,
        routingOrder: 1
    };
}

// Build full contact name
function buildContactName(Contact contact) returns string {
    string? firstName = contact.FirstName;
    string? lastName = contact.LastName;
    
    if firstName is string && lastName is string {
        return string `${firstName} ${lastName}`;
    }
    
    if lastName is string {
        return lastName;
    }
    
    if firstName is string {
        return firstName;
    }
    
    return "Contact";
}

// Validate opportunity data before processing
public function validateOpportunityData(Opportunity opportunity) returns error? {
    // Validate required fields
    string? opportunityName = opportunity.Name;
    if opportunityName is () || opportunityName.trim() == "" {
        return error("Opportunity name is required");
    }
    
    decimal? amount = opportunity.Amount;
    if amount is () {
        return error("Opportunity amount is required");
    }
    
    if amount < 0d {
        return error("Opportunity amount must be positive");
    }
    
    log:printInfo(string `Validated opportunity ${opportunity.Id}: ${opportunityName}`);
}

// Validate contact data before processing
public function validateContactData(Contact contact) returns error? {
    // Validate email
    string? contactEmail = contact.Email;
    if contactEmail is () || contactEmail.trim() == "" {
        return error("Contact email is required");
    }
    
    // Basic email validation
    if !contactEmail.includes("@") {
        return error(string `Invalid email format: ${contactEmail}`);
    }
    
    // Validate name
    string? lastName = contact.LastName;
    string? firstName = contact.FirstName;
    if (lastName is () || lastName.trim() == "") && (firstName is () || firstName.trim() == "") {
        return error("Contact must have at least first name or last name");
    }
    
    log:printInfo(string `Validated contact ${contact.Id}: ${contactEmail}`);
}
