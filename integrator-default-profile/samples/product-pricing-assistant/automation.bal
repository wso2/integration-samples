import ballerina/ai;
import ballerina/http;

listener ai:Listener productPricingListener = new (listenOn = check http:getDefaultListener());

service /product\-pricing\-assistant on productPricingListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check productPricingCoordinatorAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
