import ballerina/log;
import ballerinax/solace;

public function main() returns error? {
    do {
        solace:Message|() result = check solaceMessageconsumer->receive();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
