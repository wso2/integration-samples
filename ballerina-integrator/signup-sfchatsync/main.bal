import ballerina/http;
import ballerina/log;
import ballerinax/salesforce;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service / on httpDefaultListener {
    resource function post .(@http:Payload User payload) returns error|http:STATUS_CREATED {
        salesforce:CreationResponse|error salesforceResponse = salesforceClient->create("Contact", {
            "FirstName": payload.firstName,
            "LastName": payload.lastName,
            "Email": payload.email
        });
        if (salesforceResponse is error) {
            log:printError("Failed to create contact in Salesforce", 'error = salesforceResponse);
            return error("Failed to create contact in Salesforce");
        }
        http:Response googleChatResponse = check gChatClient->/[googleChatConfig.spaceId]/messages.post(
            {
                cardsV2: [
                    {
                        cardId: "signupCard", 
                        card: getFormattedChatMessage(payload)
                    }
                ]
            }, key = googleChatConfig.key, token = googleChatConfig.token);
        if (googleChatResponse.statusCode != http:STATUS_OK) {
            log:printError("Failed to send message to Google Chat");
            return error("Failed to send message to Google Chat");
        }
        log:printInfo("User signup processed: " + payload.firstName + " " + payload.lastName + ", " + payload.email);
        return http:STATUS_CREATED;
    }
}
