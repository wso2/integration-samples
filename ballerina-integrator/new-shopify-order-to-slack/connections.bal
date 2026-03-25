import ballerinax/slack;
import ballerinax/trigger.shopify;

// Initialize Slack client for posting messages
final slack:Client slackClient = check new slack:Client(
    config = {
        auth: {
            token: slackConfig.token
        }
    }
);

// Configure Shopify webhook listener
shopify:ListenerConfig shopifyListenerConfig = {
    apiSecretKey: shopifyConfig.apiSecretKey
};

// Initialize Shopify webhook listener
listener shopify:Listener shopifyListener = new (shopifyListenerConfig, 8090);
