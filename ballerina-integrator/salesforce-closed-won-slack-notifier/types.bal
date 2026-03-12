// Define a record type for the Slack webhook payload
type SlackWebhookPayload record {
    string text;
    string channel?;
};

// Define a record type for the opportunity details
type OpportunityDetails record {
    string name;
    decimal amount;
    string owner;
    string account;
    string wonReason;
    string stageName;
    string closeDate;
    string opportunityType;
    string leadSource;
    string competitorInfo;
    string description;
};

// Define a record type for Slack send result
type SlackSendResult record {
    string method;
};
