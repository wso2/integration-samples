import ballerina/ai;
import ballerina/http;
import ballerina/time;

listener ai:Listener meetingSchedulingListener = new (listenOn = check http:getDefaultListener());

service /meeting\-scheduling\-assistant on meetingSchedulingListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string today = time:utcToString(time:utcNow()).substring(0, 10);
        string stringResult = check meetingSchedulingAgent.run(string `Today's date (UTC) is ${today}.
${request.message}`, request.sessionId);
        return {message: stringResult};
    }
}
