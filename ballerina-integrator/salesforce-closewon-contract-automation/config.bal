// Salesforce Configuration
configurable string salesforceUsername = ?;

configurable string salesforcePassword = ?;

// DocuSign Configuration
configurable string docusignAccountId = ?;

configurable string docusignAccessToken = ?;

configurable string docusignBaseUrl = "https://demo.docusign.net/restapi";

// Template Configuration
configurable string defaultTemplateId = ?;

configurable TemplateConfig[] templateConfigs = [];

// Signer Configuration
configurable SignerRole signerRole = PRIMARY_CONTACT;

// CC Recipients Configuration
configurable CcRecipient[] ccRecipients = [];

// Field Mapping Configuration
configurable FieldMapping[] fieldMappings = [
    {opportunityField: "Name", docusignField: "OpportunityName"},
    {opportunityField: "Amount", docusignField: "ContractValue"},
    {opportunityField: "CloseDate", docusignField: "CloseDate"}
];

// Business Rules Configuration
configurable decimal minimumDealValue = 0.0;

configurable int expirationReminderDays = 3;

configurable string contractSentStage = "Contract Sent";

// Salesforce Channel Configuration
configurable string salesforceChannelName = "/data/ChangeEvents";
