// Jira Configuration
type JiraConfig record {|
    string email;
    string apiToken;
    string baseUrl;
    string projectKey;
|};

configurable JiraConfig jira = ?;

// Gmail Configuration
type GmailConfig record {|
    string clientId;
    string clientSecret;
    string refreshToken;
    string[] recipients;
|};

configurable GmailConfig gmail = ?;

// Email Configuration
type EmailConfig record {|
    string timeZone = "America/Los_Angeles";
    string subjectTemplate = "Sprint Summary: {{sprintName}}";
|};

configurable EmailConfig email = {};

// Summary Sections Toggle
type SummaryConfig record {|
    boolean includeCompletedIssues = true;
    boolean includeCarriedOverIssues = true;
    boolean includeAssigneeBreakdown = true;
    boolean includeMidSprintAdditions = true;
|};

configurable SummaryConfig summary = {};

// Lookback Configuration (permanent settings)
const decimal lookbackHours = 1460.0; // ~2 months (61 days)

// Persistence Configuration (permanent settings)
const string persistenceMethod = "jira-label";
const string processedSprintLabel = "sprint-summary-sent"; 
