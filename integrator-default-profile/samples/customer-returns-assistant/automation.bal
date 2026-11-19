import ballerina/ai;
import ballerina/http;

listener ai:Listener customerReturnsListener = new (listenOn = check http:getDefaultListener());

service /customer\-returns\-assistant on customerReturnsListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check customerReturnsAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
