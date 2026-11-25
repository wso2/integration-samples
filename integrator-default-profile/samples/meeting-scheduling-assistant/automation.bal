import ballerina/ai;
import ballerina/http;

listener ai:Listener meetingSchedulingListener = new (listenOn = check http:getDefaultListener());

service /meeting\-scheduling\-assistant on meetingSchedulingListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check meetingSchedulingAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }

    resource function post decision(@http:Payload ai:DecisionMessage request) returns ai:ChatRespMessage|error {
        ai:Resume resume = {decisions: request.decisions};
        string result = check meetingSchedulingAgent.run(resume, request.sessionId);
        return {message: result};
    }
}
