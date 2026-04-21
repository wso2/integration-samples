import ballerinax/kafka;

final kafka:Producer kafkaProducer = check new (string `${kafkaBootstrapServers}`);
