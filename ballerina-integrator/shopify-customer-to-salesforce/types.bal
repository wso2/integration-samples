import ballerina/constraint;

// Salesforce Contact record with all standard fields
public type SalesforceContact record {
    // Required fields
    @constraint:String {
        minLength: 5,
        maxLength: 80
    }
    string LastName;
    
    // Name fields
    @constraint:String {
        minLength: 1,
        maxLength: 40
    }
    string FirstName?;
    string Salutation?;
    string MiddleName?;
    string Suffix?;
    
    // Contact information
    @constraint:String {
        maxLength: 80,
        pattern: re `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
    }
    string Email?;
    @constraint:String {
        maxLength: 40,
        pattern: re `^\+?[0-9()\-\s]{7,20}$`
    }
    string Phone?;
    @constraint:String {
        maxLength: 40,
        pattern: re `^\+?[0-9()\-\s]{7,20}$`
    }
    string MobilePhone?;
    @constraint:String {
        maxLength: 40,
        pattern: re `^\+?[0-9()\-\s]{7,20}$`
    }
    string HomePhone?;
    @constraint:String {
        maxLength: 40,
        pattern: re `^\+?[0-9()\-\s]{7,20}$`
    }
    string OtherPhone?;
    @constraint:String {
        maxLength: 40,
        pattern: re `^\+?[0-9()\-\s]{7,20}$`
    }
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
    
    // Additional information
    string Title?;
    string Department?;
    string Description?;
    string AssistantName?;
    @constraint:String {
        maxLength: 40,
        pattern: re `^\+?[0-9()\-\s]{7,20}$`
    }
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
