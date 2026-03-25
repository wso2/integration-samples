public type ShopifyConfig record {|
    // This should be the webhook secret from Shopify (used for HMAC SHA256 validation)
    string shopifySecret;
|};

public type SalesforceConfig record {|
    // Salesforce OAuth2 configuration
    string salesforceBaseUrl;
    string salesforceClientId;
    string salesforceClientSecret;
    string salesforceRefreshToken;
    string salesforceRefreshUrl = "https://login.salesforce.com/services/oauth2/token";

    "company"|"domain"|"none" accountAssociationRule = "company";
|};

configurable ShopifyConfig shopifyConfig = ?;
configurable SalesforceConfig salesforceConfig = ?;
