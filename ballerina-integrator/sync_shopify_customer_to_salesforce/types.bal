// Shopify Order event types

// Shopify Product event types

// Shopify Customer event types
public type CustomerCreatedEvent record {
    string id;
    string email?;
    string first_name?;
    string last_name?;
};

public type CustomerUpdatedEvent record {
    string id;
    string email?;
    string first_name?;
    string last_name?;
};

public type CustomerDeletedEvent record {
    string id;
};

// Salesforce Contact record
public type SalesforceContact record {
    string LastName;
    string FirstName?;
    string Email?;
    string Description?;
    string AccountId?;
    string LeadSource?;
    string OwnerId?;
    string RecordTypeId?;
    string Customer_Origin__c?;
    string Shopify_Customer_ID__c?;
};

// Salesforce Account record
public type SalesforceAccount record {
    string Name;
    string Website?;
    string Description?;
};

// Salesforce query result types
public type ContactQueryResult record {|
    string Id;
    string Email?;
    string FirstName?;
    string LastName?;
    string AccountId?;
|};

public type AccountQueryResult record {|
    string Id;
    string Name;
    string Website?;
|};
