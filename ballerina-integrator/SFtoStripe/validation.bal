import ballerina/log;

// Validate Salesforce Account before syncing
public function validateAccount(SalesforceAccount account) returns error? {
    // Validate required fields
    if account?.Id is () || account?.Id == "" {
        return error("Account ID is required");
    }

    // Validate email format if present and match key is EMAIL
    if matchKey == EMAIL {
        string? email = account?.Email__c;
        if email is string && email != "" && !isValidEmail(email) {
            log:printWarn("Account has invalid email format", accountId = account?.Id, email = email);
            return error("Invalid email format");
        }
        if email is () || email == "" {
            log:printWarn("Account has no email, will create new customer without email-based matching", accountId = account?.Id);
        }
    }
    // EXTERNAL_ID uses SF Id stored in Stripe metadata — always present if Id check above passed

    return;
}

// Validate Salesforce Contact before syncing
public function validateContact(SalesforceContact contact) returns error? {
    // Validate required fields
    if contact?.Id is () || contact?.Id == "" {
        return error("Contact ID is required");
    }

    // Validate email format if present and match key is EMAIL
    if matchKey == EMAIL {
        string? email = contact?.Email;
        if email is string && email != "" && !isValidEmail(email) {
            log:printWarn("Contact has invalid email format", contactId = contact?.Id, email = email);
            return error("Invalid email format");
        }
        if email is () || email == "" {
            log:printWarn("Contact has no email, will create new customer without email-based matching", contactId = contact?.Id);
        }
    }
    // EXTERNAL_ID uses SF Id stored in Stripe metadata — always present if Id check above passed

    return;
}

// Basic email validation
isolated function isValidEmail(string email) returns boolean {
    // Simple email validation - contains @ and has characters before and after
    int? atIndex = email.indexOf("@");
    if atIndex is () || atIndex <= 0 || atIndex >= email.length() - 1 {
        return false;
    }
    
    // Check for dot after @
    string domain = email.substring(atIndex + 1);
    int? dotIndex = domain.indexOf(".");
    if dotIndex is () || dotIndex <= 0 || dotIndex >= domain.length() - 1 {
        return false;
    }
    
    return true;
}