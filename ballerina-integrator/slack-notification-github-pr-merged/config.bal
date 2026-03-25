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
    string callbackUrl = "";
    string[] repos;
} githubConfig = ?;

// Optional filters
configurable string[] filterBaseBranches = ["main"];
configurable string[] filterLabels = [];
configurable string filterAuthor = "";

// Message customization
configurable boolean includePrDescription = true;
configurable boolean includeReviewers = true;
configurable boolean includeDiffStats = true;
configurable boolean includeCycleTime = true;
