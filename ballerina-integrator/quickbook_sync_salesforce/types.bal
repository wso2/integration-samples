// Conflict Resolution Strategy
public enum ConflictResolution {
    SOURCE_WINS,
    DESTINATION_WINS,
    MOST_RECENT
}

// QuickBooks Customer Webhook Event
public type QuickBooksWebhookEvent record {
    string eventNotifications;
};

public type EventNotification record {
    string realmId;
    DataChangeEvent[] dataChangeEvent;
};

public type DataChangeEvent record {
    string[] entities;
};

public type Entity record {
    string name;
    string id;
    string operation;
    string lastUpdated;
};

// QuickBooks Customer Record
public type QuickBooksCustomer record {
    string Id;
    string DisplayName;
    string SyncToken;
    string? CompanyName?;
    string? GivenName?;
    string? FamilyName?;
    EmailAddress? PrimaryEmailAddr?;
    PrimaryPhone? PrimaryPhone?;
    FaxPhone? Fax?;
    BillAddr? BillAddr?;
    ShipAddr? ShipAddr?;
    WebAddress? WebAddr?;
    ParentRef? ParentRef?;
    string? Notes?;
    boolean? Active?;
    string? CustomerType?;
    MetaData? MetaData?;
    CustomField[]? CustomField?;
};

// QuickBooks Custom Field
public type CustomField record {
    string? DefinitionId?;
    string? StringValue?;
    string? Name?;
    string? Type?;
};

public type PrimaryPhone record {
    string? FreeFormNumber?;
};

public type FaxPhone record {
    string? FreeFormNumber?;
};

public type EmailAddress record {
    string? Address?;
};

public type WebAddress record {
    string? URI?;
};

public type MetaData record {
    string? CreateTime?;
    string? LastUpdatedTime?;
};

public type BillAddr record {
    string? Line1?;
    string? Line2?;
    string? City?;
    string? CountrySubDivisionCode?;
    string? PostalCode?;
    string? Country?;
};

public type ShipAddr record {
    string? Line1?;
    string? Line2?;
    string? City?;
    string? CountrySubDivisionCode?;
    string? PostalCode?;
    string? Country?;
};

public type ParentRef record {
    string? value?;
    string? name?;
};

// Salesforce Account Record

public type SalesforceAccount record {
    string|() Id?;
    string Name;
    string|() Site?;
    string|() Phone?;
    string|() Fax?;
    string|() Website?;
    string|() BillingStreet?;
    string|() BillingCity?;
    string|() BillingState?;
    string|() BillingPostalCode?;
    string|() BillingCountry?;
    string|() ShippingStreet?;
    string|() ShippingCity?;
    string|() ShippingState?;
    string|() ShippingPostalCode?;
    string|() ShippingCountry?;
    string|() ParentId?;
    string|() Description?;
    string|() Type?;
    string|() QuickbooksSync__c?;
    ()|string LastModifiedDate?;
};

// Salesforce Contact Record
public type SalesforceContact record {
    string? Id?;
    string LastName;
    string? FirstName?;
    string? Email?;
    string? Phone?;
    string? AccountId?;
};

// Sync Result
public type SyncResult record {
    boolean success;
    string? accountId?;
    string? contactId?;
    string? message?;
    string? errorDetails?;
};
