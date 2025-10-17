import ballerina/log;
import ballerinax/kafka;

// Kafka service to consume shipment messages and send emails
listener kafka:Listener kafkaLis = new kafka:Listener(
    bootstrapServers = kafkaBootstrapServers,
    groupId = "shipment-email-service",
    topics = [kafkaTopic],
    securityProtocol = kafka:PROTOCOL_SSL,
    secureSocket = {
        cert: kafkaCaCertPath,
        key: {
            certFile: kafkaClientCertPath,
            keyFile: kafkaClientKeyPath
        },
        protocol: {
            name: "TLS"
        }
    }
);

service on kafkaLis {
    remote function onConsumerRecord(kafka:AnydataConsumerRecord[] messages) returns error? {
        foreach kafka:AnydataConsumerRecord currentMessage in messages {
            // Extract correlation-id from headers
            string? correlationId = check getCorelationId(currentMessage.headers);

            // Handle the message value conversion
            ShipmentMessage shipmentMessage = check getShipmentRecord(currentMessage.value);

            log:printInfo("Processing shipment message",
                    shipmentId = shipmentMessage.shipmentId,
                    correlationId = correlationId
            );

            // Send email notification
            error? emailResult = sendShipmentNotification(shipmentMessage, correlationId);
            if emailResult is error {
                log:printError("Failed to send email notification",
                        'error = emailResult,
                        shipmentId = shipmentMessage.shipmentId,
                        correlationId = correlationId
                );
                return emailResult;
            }
        }
    }

    remote function onError(kafka:Error kafkaError) returns error? {
        log:printError("Kafka consumer error occurred", 'error = kafkaError);
    }
}
