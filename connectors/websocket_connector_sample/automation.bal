import ballerina/log;
import ballerina/websocket;

public function main() returns error? {
    do {
        error? result = websocketClient->writeTextMessage("Hello, WebSocket!");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
