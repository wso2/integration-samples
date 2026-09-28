import ballerina/http;
import ballerina/ai;

listener ai:Listener hrRagAgentListener = new (listenOn = check http:getDefaultListener());

service /hrRagAgent on hrRagAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string agentResponse = check llmChat(request.message);
        return {message: agentResponse};
    }
}
