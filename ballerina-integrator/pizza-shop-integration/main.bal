import ballerina/http;
import ballerinax/ai.agent;

listener agent:Listener orderManagementAgentListener = new (listenOn = check http:getDefaultListener());

service /orderManagementAgent on orderManagementAgentListener {
    resource function post chat(@http:Payload agent:ChatReqMessage request) returns agent:ChatRespMessage|error {

        string stringResult = check _orderManagementAgentAgent->run(request.message);
        return {message: stringResult};
    }
}
