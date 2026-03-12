import ballerinax/slack;
import ballerinax/trigger.shopify;

// Initialize Slack client for posting messages
final slack:Client slackClient = check new slack:Client(
    config = {
        auth: {
            token: slackToken
        }
    }
);

// Configure Shopify webhook listener
shopify:ListenerConfig shopifyListenerConfig = {
    apiSecretKey: shopifyApiSecretKey
};

// Initialize Shopify webhook listener
listener shopify:Listener shopifyListener = new (shopifyListenerConfig, 8090);
