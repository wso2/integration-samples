// Sync Direction Enum
public enum SyncDirection {
    SF_TO_STRIPE,
    STRIPE_TO_SF,
    BIDIRECTIONAL
}

// Source Object Enum
public enum SourceObject {
    ACCOUNT,
    CONTACT,
    BOTH
}

// Match Key Enum
public enum MatchKey {
    EMAIL,
    EXTERNAL_ID
}

// Salesforce Account Record
public type SalesforceAccount record {|
    string? Id?;
    string? Name?;
    string? Email__c?;
    string? Phone?;
    string? BillingStreet?;
    string? BillingCity?;
    string? BillingState?;
    string? BillingPostalCode?;
    string? BillingCountry?;
    string? ShippingStreet?;
    string? ShippingCity?;
    string? ShippingState?;
    string? ShippingPostalCode?;
    string? ShippingCountry?;
    string? Description?;
    string? Stripe_Customer_Id__c?;
    string? RecordTypeId?;
    string? AccountStatus__c?;
    anydata...;
|};

// Salesforce Contact Record
public type SalesforceContact record {|
    string? Id?;
    string? FirstName?;
    string? LastName?;
    string? Email?;
    string? Phone?;
    string? MailingStreet?;
    string? MailingCity?;
    string? MailingState?;
    string? MailingPostalCode?;
    string? MailingCountry?;
    string? OtherStreet?;
    string? OtherCity?;
    string? OtherState?;
    string? OtherPostalCode?;
    string? OtherCountry?;
    string? Description?;
    string? Stripe_Customer_Id__c?;
    string? RecordTypeId?;
    anydata...;
|};

// Stripe Customer Address
public type StripeCustomerAddress record {|
    string city?;
    string country?;
    string line1?;
|};