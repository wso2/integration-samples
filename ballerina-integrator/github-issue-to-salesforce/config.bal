// GitHub configuration
configurable record {
    string webhookSecret;
    string[] triggerLabels;
} githubConfig = ?;

// Salesforce connection configuration
configurable record {
    string baseUrl;
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl;
} salesforceConfig = ?;

// Salesforce case configuration
configurable record {
    string recordType;
    string priority;
    string status;
    string ownerId;
} caseConfig = ?;
