# OpenAI API key, for the gpt-4o-mini model the agent uses
configurable string openAiApiKey = ?;

# Google OAuth client ID, shared by Sheets, Calendar and Gmail
configurable string googleClientId = ?;

# Google OAuth client secret
configurable string googleClientSecret = ?;

# Google OAuth refresh token with the spreadsheets, calendar and gmail.send scopes
configurable string googleRefreshToken = ?;

# ID of the Google spreadsheet with the Roles and Screenings worksheets
configurable string screeningSpreadsheetId = ?;

# ID of the Google Calendar that interviews are booked on
configurable string interviewCalendarId = ?;
