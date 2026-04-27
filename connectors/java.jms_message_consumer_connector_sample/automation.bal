import ballerina/log;
import ballerinax/java.jms;

public function main() returns error? {
    do {
        jms:Message|() result = check jmsMessageconsumer->receive();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
