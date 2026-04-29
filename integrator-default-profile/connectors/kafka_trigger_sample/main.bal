import ballerina/log;
import ballerinax/kafka;

listener kafka:Listener kafkaListener = new (string `${kafkaBootstrapServers}`, topics = string `${kafkaTopic}`);

service kafka:Service on kafkaListener {
    remote function onConsumerRecord(KafkaAnydataConsumer[] messages, kafka:Caller caller) returns error? {
        do {
            log:printInfo(messages.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
