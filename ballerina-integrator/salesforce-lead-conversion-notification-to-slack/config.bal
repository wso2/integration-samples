// Salesforce configuration
configurable string salesforceBaseUrl = ?;
configurable string salesforceClientId = ?;
configurable string salesforceClientSecret = ?;
configurable string salesforceRefreshToken = ?;
configurable string salesforceRefreshUrl = ?;

// Slack configuration
configurable string slackToken = ?;
configurable string defaultSlackChannel = ?;

// Message template configuration
configurable string messageTemplate = "🎉 Lead Converted!\n*Lead:* {{lead.name}}\n*Company:* {{lead.company}}\n*Owner:* {{lead.owner}}";

// Filter configuration
configurable string[] filterLeadSources = [];
configurable string[] filterOwnerIds = [];

// Team-specific channel routing
configurable TeamChannelMapping[] teamChannelMappings = [];

// Include conversion details flag
configurable boolean includeConversionDetails = true;
