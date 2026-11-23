# OAuth 2.0 client ID of the Google Cloud app that has the Gmail API enabled.
configurable string gmailClientId = ?;
# OAuth 2.0 client secret of the Google Cloud app that has the Gmail API enabled.
configurable string gmailClientSecret = ?;
# OAuth 2.0 refresh token with the gmail.readonly scope for the mailbox to monitor.
configurable string gmailRefreshToken = ?;
# API key from ipqualityscore.com, used to look up the reputation (fraud score) of the sender IP address.
configurable string ipQualityScoreApiKey = ?;
# How often, in seconds, the inbox poller checks Gmail for new emails.
configurable decimal pollIntervalSeconds = 60;
# Gmail search query that selects which new emails the poller analyzes.
configurable string pollQuery = "in:inbox";
