import ballerina/log;
import ballerinax/nats;

public function main() returns error? {
    do {
        check natsClient->publishMessage({content: "Hello, NATS!".toBytes(), subject: "integrations.events"});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
