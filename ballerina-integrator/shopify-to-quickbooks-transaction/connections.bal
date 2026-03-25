import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// Shopify webhook listener — handles HMAC-SHA256 signature validation automatically
shopify:ListenerConfig listenerConfig = {
    apiSecretKey: shopifyConfig.apiSecretKey
};

listener shopify:Listener shopifyListener = new (listenerConfig, 8090);

// QuickBooks Online REST client — handles OAuth2 token refresh automatically on demand.
// Constructed at module initialization; no manual authentication handling is required in tests.
final quickbooks:Client quickbooksClient = check new ({
    auth: {
        clientId: quickbooksConfig.clientId,
        clientSecret: quickbooksConfig.clientSecret,
        refreshToken: quickbooksConfig.refreshToken
    }
}, quickbooksConfig.serviceUrl);