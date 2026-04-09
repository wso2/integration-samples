import ballerina/log;

public function main() returns error? {
    do {
        check kafkaProducer->send({
            topic: "orders",
            value: "Hello, Kafka World!".toBytes()
        });
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
