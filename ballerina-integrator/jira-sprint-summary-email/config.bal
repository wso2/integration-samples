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

// Polling Configuration
configurable decimal pollingIntervalHours = ?;

// Email Configuration
configurable string timeZone = "America/Los_Angeles";
configurable string emailSubjectTemplate = "Sprint Summary: {{sprintName}}";

// Summary Sections Toggle
configurable boolean includeCompletedIssues = ?;
configurable boolean includeCarriedOverIssues = ?;
configurable boolean includeAssigneeBreakdown = ?;
configurable boolean includeMidSprintAdditions = ?; 
