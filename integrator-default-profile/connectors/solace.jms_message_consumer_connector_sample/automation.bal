import ballerina/log;
import ballerinax/solace.jms;

public function main() returns error? {
    do {
        jms:Message? t = check jmsMessageconsumer->receive();
        log:printInfo(t.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
