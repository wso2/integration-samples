import ballerinax/salesforce;
import ballerinax/slack;

// Salesforce client initialization
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        clientId: salesforceClientId,
        clientSecret: salesforceClientSecret,
        refreshToken: salesforceRefreshToken,
        refreshUrl: salesforceRefreshUrl
    }
});

// Slack client initialization
final slack:Client slackClient = check new ({
    auth: {
        token: slackToken
    }
});
