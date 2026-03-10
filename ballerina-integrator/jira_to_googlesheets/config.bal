// Jira Configuration
configurable record {
    string baseUrl;
    string email;
    string apiToken;
} jiraConfig = ?;

configurable string jiraProjectKey = ?;

// Google Sheets OAuth Configuration
configurable record {
    string refreshToken;
    string clientId;
    string clientSecret;
} googleSheetsConfig = ?;

// Timezone for timestamp formatting (e.g., "Asia/Kolkata", "America/New_York")
configurable string timezone = "UTC";

// Optional: Spreadsheet ID to update existing sheet instead of creating a new one
configurable string? spreadsheetId = ();

