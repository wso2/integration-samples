import ballerina/http;
import ballerinax/salesforce;

final http:Client gChatClient = check new ("https://chat.googleapis.com/v1/spaces");

final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceConfig.baseUrl,
    auth: {
        clientId: salesforceConfig.clientId,
        clientSecret: salesforceConfig.clientSecret,
        refreshToken: salesforceConfig.refreshToken,
        refreshUrl: salesforceConfig.refreshUrl
    }
});
