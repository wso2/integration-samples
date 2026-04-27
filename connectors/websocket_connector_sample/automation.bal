import ballerina/log;
import ballerina/websocket;

public function main() returns error? {
    do {
        check websocketClient->writeTextMessage("Hello, WebSocket!");
        log:printInfo("Message sent successfully");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
