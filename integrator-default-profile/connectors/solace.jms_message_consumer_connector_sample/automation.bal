import ballerina/log;
import ballerinax/solace.jms;

public function main() returns error? {
    do {
        jms:Message? t = check jmsMessageconsumer->receive();
        if t is jms:Message {
            log:printInfo(t.toString());
        } else {
            log:printInfo("No message received");
        }
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
