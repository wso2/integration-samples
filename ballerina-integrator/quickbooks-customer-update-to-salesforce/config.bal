// Salesforce Configuration Record
public type SalesforceConfig record {|
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl;
    string baseUrl;
|};

// QuickBooks Configuration Record
public type QuickBooksConfig record {|
    string clientId;
    string clientSecret;
    string refreshToken;
    string realmId;
    string baseUrl;
    string tokenUrl = "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer";
    string verifyToken;
|};

// Sync Configuration Record
public type SyncConfig record {|
    ConflictResolution conflictResolution = SOURCE_WINS;
    boolean filterActiveOnly = true;
|};

// Grouped Configurables
configurable SalesforceConfig salesforceConfig = ?;
configurable QuickBooksConfig quickbooksConfig = ?;
configurable SyncConfig syncConfig = {};
