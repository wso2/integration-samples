import ballerinax/solace;

final solace:MessageProducer solaceMessageproducer = check new (string `${solaceUrl}`, auth = {username: solaceUsername, password: solacePassword});
