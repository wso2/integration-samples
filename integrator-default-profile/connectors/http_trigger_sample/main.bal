import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new (httpListenerPort);

service / on httpListener {
    resource function get messages() returns json|error {
        do {
            json payload = {message: "Hello from HTTP listener", path: "/messages"};
            log:printInfo(payload.toJsonString());
            return payload;
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
