import ballerinax/kafka;

final kafka:Consumer kafkaConsumer = check new (string `${kafkaBootstrapServers}`, groupId = string `${kafkaGroupId}`, clientId = string `${kafkaClientId}`);
