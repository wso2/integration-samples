// Source Object Enum
public enum SourceObject {
    ACCOUNT,
    CONTACT,
    BOTH
}

// Match Key Enum
public enum MatchKey {
    EMAIL,
    SALESFORCE_ID
}

// Salesforce Account Record
// Only includes absolutely required fields - all other fields accessed via anydata rest
public type SalesforceAccount record {|
    string? Id;
    anydata...;
|};

// Salesforce Contact Record
// Only includes absolutely required fields - all other fields accessed via anydata rest
public type SalesforceContact record {|
    string? Id;
    anydata...;
|};

// Stripe Customer Address
public type StripeCustomerAddress record {|
    string city?;
    string country?;
    string line1?;
|};