import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// Shopify webhook listener
shopify:ListenerConfig listenerConfig = {
    apiSecretKey: shopifyConfig.apiSecretKey
};

listener shopify:Listener shopifyListener = new (listenerConfig, 9090);

// QuickBooks Online REST client
final quickbooks:Client quickbooksClient = check new ({
    auth: {
        clientId: quickbooksConfig.clientId,
        clientSecret: quickbooksConfig.clientSecret,
        refreshToken: quickbooksConfig.refreshToken
    }
}, quickbooksConfig.serviceUrl);
