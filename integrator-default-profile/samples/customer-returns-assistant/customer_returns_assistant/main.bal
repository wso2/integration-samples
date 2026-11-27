import ballerina/ai;
import ballerina/http;

listener ai:Listener agentChatListener = new (listenOn = check http:getDefaultListener());

service /customer\-returns\-assistant on agentChatListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request)
            returns ai:ChatRespMessage|error {
        string stringResult = check customerReturnsAgent.run(request.message, sessionId = request.sessionId);
        return {message: stringResult};
    }
}
