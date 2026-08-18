import ballerina/log;
import ballerinax/solace;

public function main() returns error? {
    do {
        solace:Message? t = check solaceMessageconsumer->receive();
        if t is solace:Message {
            log:printInfo(t.toJsonString());
        } else {
            log:printInfo("No message received");
        }
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
