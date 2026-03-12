// GitHub repository configurations
configurable string[] githubRepositories = ?;

// GitHub webhook secret for secure webhook verification
configurable string githubWebhookSecret = ?;

// Configurable list of labels that trigger the workflow
configurable string[] triggerLabels = ?;

// Salesforce connection configurations
configurable string salesforceBaseUrl = ?;
configurable string salesforceAccessToken = ?;

// Salesforce case configurations
configurable string caseRecordType = "";
configurable string casePriority = "Medium";
configurable string caseStatus = "New";
configurable string caseOwnerId = ?;

