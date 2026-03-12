// Shopify webhook configuration
// This should be the webhook secret from Shopify (used for HMAC SHA256 validation)
configurable string shopifySecret = ?;
configurable int port = 8090;

// Salesforce OAuth2 configuration
configurable string salesforceBaseUrl = ?;
configurable string salesforceClientId = ?;
configurable string salesforceClientSecret = ?;
configurable string salesforceRefreshToken = ?;
configurable string salesforceRefreshUrl = "https://login.salesforce.com/services/oauth2/token";

// Salesforce default values
configurable string defaultLeadSource = "Shopify";
configurable string? defaultRecordTypeId = ();
configurable string? ownerIdDefault = ();
configurable "company"|"domain"|"none" accountAssociationRule = "company";
configurable boolean enableDuplicateCheck = true;

// HTTP listener configuration for Shopify webhooks
public type ShopifyListenerConfig record {|
    int port = 8090;
|};
