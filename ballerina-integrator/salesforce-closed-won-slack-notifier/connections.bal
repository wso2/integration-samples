import ballerinax/salesforce;
import ballerinax/slack;

// Salesforce client configuration
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceConfig.baseUrl,
    auth: {
        refreshUrl: salesforceConfig.refreshUrl,
        refreshToken: salesforceConfig.refreshToken,
        clientId: salesforceConfig.clientId,
        clientSecret: salesforceConfig.clientSecret
    }
});

// Slack client configuration
final slack:Client slackClient = check new ({
    auth: {
        token: slackConfig.slackToken
    }
});
