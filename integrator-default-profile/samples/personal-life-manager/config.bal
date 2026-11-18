configurable string telegramBotToken = ?;
configurable string telegramCallbackUrl = ?;
configurable int allowedChatId = ?;

// Single set of Google OAuth credentials shared across Gmail, Calendar, and Tasks
configurable string googleClientId = ?;
configurable string googleClientSecret = ?;
configurable string googleRefreshToken = ?;

configurable string calendarId = "primary";
configurable string tasksListId = "@default";
// UTC offset in minutes for calendar "today" calculation; e.g. 330 for Asia/Colombo (UTC+5:30)
configurable int calendarTimeZone = 0;

configurable string groqApiKey = ?;
