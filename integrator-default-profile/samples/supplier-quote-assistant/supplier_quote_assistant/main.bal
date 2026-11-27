import ballerina/ai;
import ballerina/http;

listener ai:Listener agentChatListener = new (listenOn = check http:getDefaultListener());

service /supplier\-quote\-assistant on agentChatListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request)
            returns ai:ChatRespMessage|error {
        string stringResult = check supplierQuoteAgent.run(request.message, sessionId = request.sessionId);
        return {message: stringResult};
    }
}
