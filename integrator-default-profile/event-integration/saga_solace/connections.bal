import ballerinax/solace;

final solace:MessageProducer sagaProducer = check new (
    solaceUrl,
    {
        messageVpn: messageVpn,
        auth: {username: solaceUser, password: solacePassword}
    }
);
