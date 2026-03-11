import ballerinax/trigger.shopify;

// Map Shopify customer event to Salesforce contact with all required fields
public function mapShopifyCustomerToSalesforceContact(
    shopify:CustomerEvent customerEvent,
    string? accountId = ()
) returns SalesforceContact {
    string? firstName = customerEvent?.first_name;
    string? lastName = customerEvent?.last_name;
    string? email = customerEvent?.email;
    int? customerId = customerEvent?.id;
    
    SalesforceContact contact = {
        LastName: lastName ?: "Unknown",
        FirstName: firstName,
        Email: email,
        Description: string `Shopify Customer ID: ${customerId.toString()}`,
        AccountId: accountId,
        LeadSource: defaultLeadSource
    };
    
    // Only include OwnerId if it's provided and not empty
    string? ownerId = defaultOwnerId;
    if ownerId is string && ownerId.trim() != "" {
        contact.OwnerId = ownerId;
    }
    
    return contact;
}

// Extract domain from email for account matching
public function extractDomainFromEmail(string email) returns string? {
    int? atIndex = email.indexOf("@");
    if atIndex is int && atIndex > 0 {
        return email.substring(atIndex + 1);
    }
    return ();
}

// Extract company name from customer event
public function extractCompanyName(shopify:CustomerEvent customerEvent) returns string? {
    // Company information may be in tags or note fields
    // This is a placeholder - adjust based on actual Shopify data structure
    return ();
}
