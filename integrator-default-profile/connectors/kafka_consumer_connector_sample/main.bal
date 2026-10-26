import ballerina/log;
import ballerinax/kafka;

// Creates a Kafka listener using the configurable bootstrapServers
listener kafka:Listener kafkaListener = new (string `${kafkaBootstrapServers}`, {
    groupId: string `${kafkaGroupId}`,
    topics: [string `${kafkaTopic}`],
    offsetReset: kafka:OFFSET_RESET_LATEST, // skip old messages, only consume new ones
    pollingInterval: 1,
    autoCommit: false // required when using caller->commit()
});

service kafka:Service on kafkaListener {

    remote function onConsumerRecord(kafka:AnydataConsumerRecord[] messages, kafka:Caller caller) returns error? {
        boolean batchHasFailure = false;
        foreach kafka:AnydataConsumerRecord msg in messages {
            do {
                byte[] msgBytes = check msg.value.ensureType();
                string jsonStr = check string:fromBytes(msgBytes);
                OrderEvent orderEvent = check jsonStr.fromJsonStringWithType();
                processOrder(orderEvent); // Implement a processing logic under processOrder() method in functions.bal file
                log:printInfo("onConsumerRecord triggered", orderId = orderEvent.orderId);
            } on fail error e {
                batchHasFailure = true;
                log:printError("Failed to process message; offsets will not be committed and the batch will be retried", 'error = e, offset = msg.offset.offset, partition = msg.offset.partition.partition);
            }
        }
        if (!batchHasFailure) {
            check caller->commit();
        } else {
            log:printInfo("Skipping offset commit because at least one message in the batch failed; the batch will be re-delivered");
        }
    }
}