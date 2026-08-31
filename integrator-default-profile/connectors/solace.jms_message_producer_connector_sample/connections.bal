import ballerinax/solace.jms;

final jms:MessageProducer jmsMessageproducer = check new (string `${solaceJmsUrl}`, auth = {username: solaceJmsUsername, password: solaceJmsPassword});
