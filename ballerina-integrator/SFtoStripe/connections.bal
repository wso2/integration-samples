import ballerinax/salesforce;
import ballerinax/stripe;

// Salesforce Client
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceConfig.baseUrl,
    auth: getSalesforceAuthConfig()
});

// Stripe Client
final stripe:Client stripeClient = check new ({
    auth: getStripeAuthConfig()
});