import ballerinax/salesforce;
import ballerinax/trigger.shopify;

// Salesforce client initialization with OAuth2 refresh token grant
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceConfig.baseUrl,
    auth: {
        clientId: salesforceConfig.clientId,
        clientSecret: salesforceConfig.clientSecret,
        refreshToken: salesforceConfig.refreshToken,
        refreshUrl: salesforceConfig.refreshUrl
    }
});

// Shopify webhook listener configuration
shopify:ListenerConfig shopifyListenerConfig = {
    apiSecretKey: shopifyConfig.apiSecretKey
};
listener shopify:Listener shopifyListener = new (shopifyListenerConfig, 9090);
