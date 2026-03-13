import ballerina/http;
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

// Raw Slack HTTP client for APIs with broken connector type bindings
final http:Client slackHttpClient = check new ("https://slack.com", {
    auth: {token: slackToken}
});
