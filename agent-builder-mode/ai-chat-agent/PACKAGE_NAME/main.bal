import ballerina/ai;
import ballerina/http;

listener ai:Listener chatAgentListener = new (listenOn = check http:getDefaultListener());

service /AGENT_NAME on chatAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check AGENT_NAMEAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
