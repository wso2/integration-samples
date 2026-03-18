// Slack configuration
configurable string slackToken = ?;
configurable string slackChannelId = ?;

// GitHub webhook configuration
configurable int webhookPort = 8090;
configurable string githubCallback = "";

// GitHub repository (org/repo format)
configurable string[] githubRepos = ?;

// Optional filters
configurable string[] filterBaseBranches = ["main"];
configurable string[] filterLabels = [];
configurable string filterAuthor = "";

// Message customization
configurable boolean includePrDescription = true;
configurable boolean includeReviewers = true;
configurable boolean includeDiffStats = true;
configurable boolean includeCycleTime = true;

// Channel routing - separate channels per repo or branch
// Format: "repo:channel" or "repo/branch:channel"
// Example: ["TharaniDJ/devant:C123456", "TharaniDJ/devant/main:C789012"]
configurable string[] channelRouting = [];
