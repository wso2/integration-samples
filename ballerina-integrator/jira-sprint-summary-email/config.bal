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
configurable boolean includeCompletedIssues = true; 
configurable boolean includeCarriedOverIssues = true; 
configurable boolean includeAssigneeBreakdown = true; 
configurable boolean includeMidSprintAdditions = true; 
