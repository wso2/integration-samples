import ballerinax/solace;

final solace:MessageConsumer solaceMessageconsumer = check new (string `${solaceUrl}`, auth = {username: solaceUsername, password: solacePassword}, subscriptionConfig = {queueName: solaceQueueName}, messageVpn = solaceMessageVpn);
