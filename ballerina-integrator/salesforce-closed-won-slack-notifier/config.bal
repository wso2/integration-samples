// Salesforce Configuration
configurable record {
    string refreshToken;
    string clientId;
    string clientSecret;
    string refreshUrl;
    string baseUrl;
} salesforceConfig = ?;

// Slack Configuration
configurable record {
    string slackToken;
    string slackChannel;
    string slackWebhookUrl;
} slackConfig = ?;

// Business Logic Configuration
configurable decimal minDealAmount = 3000.0;
configurable string[] allowedTypes = [];
configurable string[] allowedOwners = [];
configurable string[] ownerSlackMapping = [];
configurable string[] dealSizeTierChannels = [];
