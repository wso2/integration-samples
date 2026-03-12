import ballerina/http;
import ballerinax/salesforce;
import ballerinax/slack;

// Salesforce client configuration
final salesforce:Client salesforceClient = check new ({
    baseUrl: baseUrl,
    auth: {
        refreshUrl: refreshUrl,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
});

// Slack client configuration
final slack:Client slackClient = check new ({
    auth: {
        token: slackToken
    }
});

// Webhook client configuration
final http:Client webhookClient = check new (slackWebhookUrl);
