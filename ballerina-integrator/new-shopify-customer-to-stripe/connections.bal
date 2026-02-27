import ballerinax/trigger.shopify;
import ballerinax/stripe;

shopify:ListenerConfig listenerConfig = {
    apiSecretKey: shopifyConfig.apiSecretKey
};

listener shopify:Listener shopifyListener = new(listenerConfig, 8090);

stripe:ConnectionConfig configuration = {
    auth: {
        token: stripeConfig.secretKey
    }
};

stripe:Client stripe = check new (configuration);
