import ballerina/http;
import ballerinax/ai.agent;

listener agent:Listener mathTutorListener = new (listenOn = check http:getDefaultListener());

service / on mathTutorListener {
    resource function post chat(@http:Payload agent:ChatReqMessage request) returns agent:ChatRespMessage|error {

        string stringResult = check _mathTutorAgent->run(request.message);
        return {message: stringResult};
    }
}
