// Salesforce Opportunity record
public type Opportunity record {
    string Id;
    string Name;
    string StageName;
    decimal Amount?;
    string AccountId?;
    string Type?;
    string CloseDate?;
};

// Salesforce Contact record
public type Contact record {
    string Id;
    string FirstName?;
    string LastName;
    string Email;
    string AccountId?;
};

// Salesforce OpportunityContactRole record
public type OpportunityContactRole record {
    string Id;
    string OpportunityId;
    string ContactId;
    string Role?;
    boolean IsPrimary?;
};

// Note: DocuSign types are now provided by ballerinax/docusign.dsesign connector
// Custom types for our specific use case

// Simplified envelope creation request
public type EnvelopeRequest record {
    string emailSubject;
    string templateId;
    SignerInfo[] signers;
    CarbonCopy[] carbonCopies?;
    record {string name; string value;}[] templateFields?;
    int expirationDays?;
};

// Signer information
public type SignerInfo record {
    string email;
    string name;
    string roleName;
    int routingOrder?;
};

// Carbon copy recipient
public type CarbonCopy record {
    string email;
    string name;
    int routingOrder?;
};

// Template Configuration
public type TemplateConfig record {
    string templateId;
    string productType?;
    string dealType?;
    int expirationDays?;
};

// Signer Role Mapping
public enum SignerRole {
    PRIMARY_CONTACT = "Primary Contact",
    BILLING_CONTACT = "Billing Contact",
    DECISION_MAKER = "Decision Maker",
    EXECUTIVE_SPONSOR = "Executive Sponsor"
}

// CC Recipient
public type CcRecipient record {
    string email;
    string name;
};

// Field Mapping Configuration
public type FieldMapping record {
    string opportunityField;
    string docusignField;
};

// Salesforce Configuration Record
public type SalesforceConfig record {|
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl = "https://login.salesforce.com/services/oauth2/token";
    string baseUrl = "https://login.salesforce.com";
|};

// DocuSign Configuration Record
public type DocusignConfig record {|
    string accountId;
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl = "https://account-d.docusign.com/oauth/token";
    string baseUrl = "https://demo.docusign.net/restapi";
|};

// Template Settings Record
public type TemplateSettings record {|
    string defaultTemplateId;
    TemplateConfig[] templateConfigs;
|};

// Business Rules Configuration Record
public type BusinessRulesConfig record {|
    decimal minimumDealValue;
    SignerRole signerRole;
    CcRecipient[] ccRecipients;
    FieldMapping[] fieldMappings;
    string contractSentStage;
    int expirationReminderDays;
|};
