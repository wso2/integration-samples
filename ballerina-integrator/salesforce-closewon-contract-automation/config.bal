// Salesforce Configuration
configurable SalesforceConfig salesforceConfig = ?;

// DocuSign Configuration
configurable DocusignConfig docusignConfig = ?;

// Template Configuration
configurable TemplateSettings templateSettings = {
    defaultTemplateId: "",
    templateConfigs: []
};

// Business Rules Configuration
configurable BusinessRulesConfig businessRulesConfig = {
    minimumDealValue: 0.0,
    signerRole: PRIMARY_CONTACT,
    ccRecipients: [],
    fieldMappings: [
        {opportunityField: "Name", docusignField: "OpportunityName"},
        {opportunityField: "Amount", docusignField: "ContractValue"},
        {opportunityField: "CloseDate", docusignField: "CloseDate"}
    ],
    contractSentStage: "Contract Sent",
    expirationReminderDays: 3
};
