// Salesforce Configuration
configurable string salesforceClientId = ?;
configurable string salesforceClientSecret = ?;
configurable string salesforceRefreshToken = ?;
configurable string salesforceRefreshUrl = ?;
configurable string salesforceBaseUrl = ?;

// QuickBooks API Configuration
configurable string quickbooksClientId = ?;
configurable string quickbooksClientSecret = ?;
configurable string quickbooksRefreshToken = ?;
configurable string quickbooksRealmId = ?;
// Base URL - Override in Config.toml for sandbox vs production
// Sandbox: https://sandbox-quickbooks.api.intuit.com/v3/company
// Production: https://quickbooks.api.intuit.com/v3/company
configurable string quickbooksBaseUrl = ?;
configurable string quickbooksTokenUrl = "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer";

// QuickBooks Webhook Configuration
configurable int webhookPort = 8080;
configurable string webhookVerifyToken = ?;

// Sync Configuration
configurable ConflictResolution conflictResolution = SOURCE_WINS;
configurable boolean filterActiveOnly = true;
configurable boolean createContact = false;
