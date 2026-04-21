import ballerinax/solace;

final solace:MessageProducer solaceMessageproducer = check new (string `${solaceHostUrl}`, messageVpn = string `${solaceMessageVpn}`, auth = {username: solaceUsername, password: solacePassword}, destination = {topicName: solaceTopicName});
