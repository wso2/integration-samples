import ballerina/log;
import ballerinax/kafka;

// Creates a Kafka producer using the configurable bootstrapServers
kafka:Producer kafkaProducer = check new (string `${kafkaBootstrapServers}`);

listener kafka:Listener kafkaListener = new (string `${kafkaBootstrapServers}`, {
    groupId: string `${kafkaGroupId}`,
    topics: [string `${kafkaTopic}`],
    offsetReset: kafka:OFFSET_RESET_LATEST, // skip old messages, only consume new ones
    pollingInterval: 1,
    autoCommit: false // required when using caller->commit()
});

service kafka:Service on kafkaListener {

    remote function onConsumerRecord(kafka:AnydataConsumerRecord[] messages, kafka:Caller caller) returns error? {
        foreach kafka:AnydataConsumerRecord msg in messages {
            do {
                byte[] msgBytes = check msg.value.ensureType();
                string jsonStr = check string:fromBytes(msgBytes);
                OrderEvent orderEvent = check jsonStr.fromJsonStringWithType();
                processOrder(orderEvent); // Implement a processing logic under processOrder() method in functions.bal file
                log:printInfo("onConsumerRecord triggered", orderId = orderEvent.orderId);
            } on fail error e {
                log:printError("Failed to process message, skipping", 'error = e, offset = msg.offset.offset, partition = msg.offset.partition.partition);
            }
        }
        check caller->commit();
    }
}