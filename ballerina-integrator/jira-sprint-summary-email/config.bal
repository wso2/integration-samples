// Jira Configuration
configurable string jiraEmail = ?;
configurable string jiraApiToken = ?;
configurable string jiraBaseUrl = ?;
configurable string jiraProjectKey = ?;

// Gmail Configuration
configurable string gmailClientId = ?;
configurable string gmailClientSecret = ?;
configurable string gmailRefreshToken = ?;
configurable string[] gmailRecipients = ?;

// Lookback Configuration (permanent settings)
const decimal lookbackHours = 1460.0; // ~2 months (61 days)

// Persistence Configuration (permanent settings)
const string persistenceMethod = "jira-label";
const string processedSprintLabel = "sprint-summary-sent";

// Email Configuration
configurable string timeZone = "America/Los_Angeles";
configurable string emailSubjectTemplate = "Sprint Summary: {{sprintName}}";

// Summary Sections Toggle
configurable boolean includeCompletedIssues = ?;
configurable boolean includeCarriedOverIssues = ?;
configurable boolean includeAssigneeBreakdown = ?;
configurable boolean includeMidSprintAdditions = ?; 
