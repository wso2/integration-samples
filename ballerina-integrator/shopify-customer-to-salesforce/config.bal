public type ShopifyConfig record {|
    // This should be the webhook secret from Shopify (used for HMAC SHA256 validation)
    string apiSecretKey;
|};

public type SalesforceConfig record {|
    // Salesforce OAuth2 configuration
    string baseUrl;
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl = "https://login.salesforce.com/services/oauth2/token";

    "company"|"domain"|"none" accountAssociationRule = "company";
|};

configurable ShopifyConfig shopifyConfig = ?;
configurable SalesforceConfig salesforceConfig = ?;
