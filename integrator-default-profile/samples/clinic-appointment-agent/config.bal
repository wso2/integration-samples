# OpenAI API key, for the gpt-4o-mini model both agents use
configurable string openAiApiKey = ?;

# Google OAuth client ID, shared by Calendar, Sheets and Gmail
configurable string googleClientId = ?;

# Google OAuth client secret
configurable string googleClientSecret = ?;

# Google OAuth refresh token with the calendar, spreadsheets and gmail.send scopes
configurable string googleRefreshToken = ?;

# ID of the Google spreadsheet that stores the clinic data
configurable string clinicSpreadsheetId = ?;

# ID of the Google Calendar that holds the clinic appointments
configurable string clinicCalendarId = ?;

# Path to the service account key file of the project that hosts the Google Chat app
configurable string googleServiceAccountFile = ?;

# Public HTTP endpoint URL set in the Google Chat app configuration (port 8000)
configurable string googleChatEndpointUrl = ?;

# Token you also enter in the WhatsApp webhook settings, used to verify the webhook
configurable string whatsappVerifyToken = ?;

# WhatsApp app secret, used to validate incoming webhook signatures
configurable string whatsappAppSecret = ?;

# WhatsApp Business Cloud API access token
configurable string whatsappAccessToken = ?;

# Telegram bot token from @BotFather
configurable string telegramBotToken = ?;

# Public URL (port 8091) where the Telegram webhook is registered on startup
configurable string telegramCallbackUrl = ?;

# ID of the front desk Google Chat space (the part after spaces/ in its URL)
configurable string frontDeskSpaceId = ?;
