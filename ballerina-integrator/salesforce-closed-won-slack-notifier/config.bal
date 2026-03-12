// Salesforce Configuration
configurable string baseUrl = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string username = ?;
configurable string password = ?;

// Slack Configuration
configurable string slackToken = ?;
configurable string slackChannel = ?;
configurable string slackWebhookUrl = ?;

// Business Logic Configuration
configurable decimal minDealAmount = 3000.0;
configurable string[] allowedRecordTypes = [];
configurable string[] allowedOwners = [];
configurable string[] ownerSlackMapping = [];
configurable string[] dealSizeTierChannels = [];
