import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// Shopify webhook listener — handles HMAC-SHA256 signature validation automatically
shopify:ListenerConfig listenerConfig = {
    apiSecretKey: shopifyConfig.apiSecretKey
};

listener shopify:Listener shopifyListener = new (listenerConfig, 8090);

// QuickBooks Online REST client — handles OAuth2 token refresh automatically
// Initialized lazily to avoid authentication during test module initialization
final quickbooks:Client quickbooksClient = check new ({
    auth: {
        clientId: quickbooksConfig.clientId,
        clientSecret: quickbooksConfig.clientSecret,
        refreshToken: quickbooksConfig.refreshToken
    }
}, quickbooksConfig.serviceUrl);
