import ballerinax/solace.jms;

final jms:MessageConsumer jmsMessageconsumer = check new (string `${solaceJmsUrl}`, auth = {username: solaceJmsUsername, password: solaceJmsPassword}, subscriptionConfig = {queueName: solaceJmsQueueName});
