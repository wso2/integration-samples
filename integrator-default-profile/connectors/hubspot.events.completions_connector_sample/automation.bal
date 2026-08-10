import ballerina/http;
import ballerina/log;

public function main() returns error? {
    do {
        http:Response httpResponse = check completionsClient->sendEvent({eventName: eventName, email: "visitor@example.com", properties: {"plan": "pro"}});
        log:printInfo("Event sent, status: " + httpResponse.statusCode.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
