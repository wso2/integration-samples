// Gmail OAuth configuration
configurable string gmailClientId = ?;
configurable string gmailClientSecret = ?;
configurable string gmailRefreshToken = ?;

// Salesforce connection configuration
configurable string salesforceBaseUrl = ?;
configurable string salesforceClientId = ?;
configurable string salesforceClientSecret = ?;
configurable string salesforceTokenUrl = ?;

// Automation configuration
configurable string gmailSearchQuery = "label:Inquiry is:unread";
configurable decimal pollingIntervalSeconds = 120;
