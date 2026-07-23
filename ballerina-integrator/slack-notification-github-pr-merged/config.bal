// Slack configuration
configurable record {
    string token;
    string channelId;
    // Channel routing - separate channels per repo or branch
    // Format: "repo:channel" or "repo/branch:channel"
    // Example: ["TharaniDJ/devant:C123456", "TharaniDJ/devant/main:C789012"]
    string[] channelRouting = [];
} slackConfig = ?;

// GitHub webhook configuration
configurable record {
    string webhookSecret;
    string[] filterBaseBranches = ["main"];
    string[] filterLabels = [];
    string filterAuthor = "";
} githubConfig = ?;

// Message customization
configurable boolean includePrDescription = true;
configurable boolean includeReviewers = true;
configurable boolean includeDiffStats = true;
configurable boolean includeCycleTime = true;
