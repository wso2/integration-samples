import ballerinax/asb;

final asb:MessageSender notificationSender = check new ({
    connectionString: connectionString,
    entityType: asb:QUEUE,
    topicOrQueueName: queueName
});
