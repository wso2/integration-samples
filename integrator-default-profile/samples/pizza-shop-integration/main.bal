import ballerina/http;
import ballerinax/ai;

listener ai:Listener orderManagementAgentListener = new (listenOn = check http:getDefaultListener());

service /orderManagementAgent on orderManagementAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check _orderManagementAgentAgent->run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
