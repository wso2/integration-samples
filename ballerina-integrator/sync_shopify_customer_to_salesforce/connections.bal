import ballerinax/trigger.shopify;
import ballerinax/salesforce;

// Event listener: Shopify webhook listener for customer events
listener shopify:Listener shopifyListener = new ({apiSecretKey: shopifyApiSecretKey}, 8090);

// Salesforce client for creating and updating contacts
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        clientId: salesforceClientId,
        clientSecret: salesforceClientSecret,
        refreshToken: salesforceRefreshToken,
        refreshUrl: salesforceRefreshUrl
    }
});

