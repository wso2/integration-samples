import ballerina/log;
import ballerinax/kafka;

public function main() returns error? {
    do {
        kafka:AnydataConsumerRecord[] pollResult = check kafkaConsumer->poll(5);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
