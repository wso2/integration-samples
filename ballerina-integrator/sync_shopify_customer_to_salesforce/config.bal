// Shopify webhook configuration
configurable string shopifySecret = ?;
configurable int port = 8090;

// Salesforce OAuth2 configuration
configurable string salesforceBaseUrl = ?;
configurable string salesforceClientId = ?;
configurable string salesforceClientSecret = ?;
configurable string salesforceRefreshToken = ?;
configurable string salesforceRefreshUrl = "https://login.salesforce.com/services/oauth2/token";

// Salesforce default values
configurable string defaultRecordType = "Standard";
configurable string defaultLeadSource = "Shopify";
configurable string defaultOwnerId = ?;

// HTTP listener configuration for Shopify webhooks
public type ShopifyListenerConfig record {|
    int port = 8090;
|};
