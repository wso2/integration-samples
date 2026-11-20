import ballerina/ai;
import ballerina/http;
import ballerinax/ai.wso2.integration;

listener integration:CloudVoiceListener voiceListener = new (8080);

isolated service integration:VoiceService on voiceListener {
    isolated remote function onChatMessage(integration:ChatMessage message) returns string|error {
        string response = check screeningAgent.run(message.message, sessionId = message.sessionId);
        return response;
    }
}

listener ai:Listener agentChatListener = new (listenOn = check http:getDefaultListener());

service /screening\-agent on agentChatListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request)
            returns ai:ChatRespMessage|error {
        string stringResult = check screeningAgent.run(request.message, sessionId = request.sessionId);
        return {message: stringResult};
    }
}

