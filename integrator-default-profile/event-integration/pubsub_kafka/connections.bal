import ballerinax/kafka;

final kafka:Producer pageViewProducer = check new (bootstrapServers);
