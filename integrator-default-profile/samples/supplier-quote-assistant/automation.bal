import ballerina/ai;
import ballerina/http;

listener ai:Listener supplierQuoteListener = new (listenOn = check http:getDefaultListener());

service /supplier\-quote\-assistant on supplierQuoteListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check supplierQuoteAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
