import ballerinax/asb;

final asb:MessageSender asbMessagesender = check new ({entityType: "topic", topicOrQueueName: asbEntityPath, connectionString: asbConnectionString});
