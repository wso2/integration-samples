import ballerina/http;
import ballerinax/mailchimp;
import ballerinax/trello;

final trello:Client trelloClient = check new ({
    'key: trelloConfig.key,
    token: trelloConfig.token
});

final http:Client trelloHttpClient = check new ("https://api.trello.com/1");
#Had to use a separate client for Trello API calls as the trello:Client does not support all endpoints needed for fetching card details and attachments.

final mailchimp:Client mailchimpClient = check new (
    config = {
        auth: {
            username: "anystring",
            password: mailchimpConfig.apiKey
        }
    },
    serviceUrl = string `https://${mailchimpConfig.serverPrefix}.api.mailchimp.com/3.0`
);
