import ballerina/http;
import ballerinax/ai;

listener ai:Listener MathTutorListener = new (listenOn = check http:getDefaultListener());

service /MathTutor on MathTutorListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {

        string stringResult = check _MathTutorAgent->run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
