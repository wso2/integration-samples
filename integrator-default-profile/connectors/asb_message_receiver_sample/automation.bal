import ballerina/log;
import ballerinax/asb;

public function main() returns error? {
    do {
        asb:Message? result = check asbMessagereceiver->receive();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
