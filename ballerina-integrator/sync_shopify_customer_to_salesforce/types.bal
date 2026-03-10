// Shopify Order event types
public type OrderCreatedEvent record {
    string id;
    string email?;
    decimal total_price?;
    string financial_status?;
    string fulfillment_status?;
};

public type OrderUpdatedEvent record {
    string id;
    string email?;
    decimal total_price?;
    string financial_status?;
    string fulfillment_status?;
};

public type OrderCancelledEvent record {
    string id;
    string cancel_reason?;
    string cancelled_at?;
};

// Shopify Product event types
public type ProductCreatedEvent record {
    string id;
    string title;
    string product_type?;
    string vendor?;
};

public type ProductUpdatedEvent record {
    string id;
    string title;
    string product_type?;
    string vendor?;
};

public type ProductDeletedEvent record {
    string id;
};

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
