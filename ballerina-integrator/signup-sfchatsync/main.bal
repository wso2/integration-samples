import ballerina/http;
import ballerina/log;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service / on httpDefaultListener {
    resource function post .(@http:Payload User payload) returns error|json {
        do {
            _ = check salesforceClient->create("Contact", {
                "FirstName": payload.firstName,
                "LastName": payload.lastName,
                "Email": payload.email
            });
            json _ = check gChatClient->/[googleChatConfig.spaceId]/messages.post(
                {
                    cardsV2: [
                        {
                            cardId: "signupCard", 
                            card: getFormattedChatMessage(payload)
                        }
                    ]
                }, key = googleChatConfig.key, token = googleChatConfig.token);
            log:printInfo("User signup processed: " + payload.firstName + " " + payload.lastName + ", " + payload.email);
            return {"status": "Success"};
        } on fail error err {
            return error("unhandled error", err);
        }
    }
}
