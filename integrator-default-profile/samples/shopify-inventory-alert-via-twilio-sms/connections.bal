import ballerinax/trigger.shopify;
import ballerinax/shopify.admin;
import ballerinax/twilio;

shopify:ListenerConfig listenerConfig = {
    apiSecretKey: shopifyConfig.apiSecretKey
};

listener shopify:Listener shopifyListener = new (listenerConfig, 8090);

// Twilio client
final twilio:Client twilioClient = check new ({
    auth: {
        accountSid: twilioConfig.accountSid,
        authToken: twilioConfig.authToken
    }
});

// Shopify admin client (used to fetch current inventory levels for ordered products)
final admin:Client adminClient = check new ({
    xShopifyAccessToken: shopifyConfig.accessToken
}, shopifyConfig.storeUrl);
