// Salesforce Contact record with all standard fields
public type SalesforceContact record {
    // Required fields
    string LastName;
    
    // Name fields
    string FirstName?;
    string Salutation?;
    string MiddleName?;
    string Suffix?;
    
    // Contact information
    string Email?;
    string Phone?;
    string MobilePhone?;
    string HomePhone?;
    string OtherPhone?;
    string Fax?;
    
    // Mailing address
    string MailingStreet?;
    string MailingCity?;
    string MailingState?;
    string MailingPostalCode?;
    string MailingCountry?;
    
    // Other address
    string OtherStreet?;
    string OtherCity?;
    string OtherState?;
    string OtherPostalCode?;
    string OtherCountry?;
    
    // Account relationship
    string AccountId?;
    
    // Marketing and communication preferences
    boolean HasOptedOutOfEmail?;
    boolean HasOptedOutOfFax?;
    boolean DoNotCall?;
    
    // Lead and ownership
    string LeadSource?;
    string OwnerId?;
    string RecordTypeId?;
    
    // Additional information
    string Title?;
    string Department?;
    string Description?;
    string AssistantName?;
    string AssistantPhone?;
    
    // Dates
    string Birthdate?;
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
