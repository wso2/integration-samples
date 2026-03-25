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
    // SALESFORCE_ID uses SF Id stored in Stripe metadata — always present if Id check above passed

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
    // SALESFORCE_ID uses SF Id stored in Stripe metadata — always present if Id check above passed

    return;
}

// Email validation using regex pattern
isolated function isValidEmail(string email) returns boolean {
    string:RegExp emailPattern = re `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$`;
    return emailPattern.isFullMatch(email);
}