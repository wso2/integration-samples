import ballerina/ai;
import ballerina/http;
import ballerina/time;

listener ai:Listener supplierQuoteListener = new (listenOn = check http:getDefaultListener());

service /supplier\-quote\-assistant on supplierQuoteListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string today = time:utcToString(time:utcNow()).substring(0, 10);
        string stringResult = check supplierQuoteAgent.run(string `Today's date (UTC) is ${today}.
${request.message}`, request.sessionId);
        return {message: stringResult};
    }
}
