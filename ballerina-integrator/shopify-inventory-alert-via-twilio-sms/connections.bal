import ballerinax/shopify.admin;
import ballerinax/twilio;

// Twilio client
final twilio:Client twilioClient = check new ({
    auth: {
        accountSid: twilioAccountSid,
        authToken: twilioAuthToken
    }
});

// Shopify admin client
final admin:Client adminClient = check new ({
    xShopifyAccessToken: shopifyAccessToken
}, shopifyStoreUrl);
