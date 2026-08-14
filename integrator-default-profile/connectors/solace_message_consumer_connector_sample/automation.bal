import ballerina/log;
import ballerinax/solace;

public function main() returns error? {
    do {
        solace:Message? t = check solaceMessageconsumer->receive();
        log:printInfo(t.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
