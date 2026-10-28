import ballerina/ai;
import ballerina/http;
import ballerinax/ai.wso2.integration;

listener ai:Listener chatAgentListener = new (listenOn = check http:getDefaultListener());

service /customer\-support\-agent on chatAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check customerSupportAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}

listener integration:CloudVoiceListener voiceListener = new (8080);

isolated service integration:VoiceService on voiceListener {
    isolated remote function onChatMessage(integration:ChatMessage message) returns string|error {
        string response = check customerSupportAgent.run(message.message, message.sessionId);
        return response;
    }
}
