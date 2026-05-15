import ballerina/ai;
import ballerina/http;

listener ai:Listener mathTutorListener = new (listenOn = check http:getDefaultListener());

service /MathTutor on mathTutorListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check mathTutorAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
