import ballerinax/solace;

final solace:MessageConsumer solaceMessageconsumer = check new (string `${solaceHostUrl}`, subscriptionConfig = {queueName: solaceQueueName});
