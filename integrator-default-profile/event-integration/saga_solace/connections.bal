import ballerinax/solace;

final solace:MessageProducer flightBookedProducer = check new (
    solaceUrl,
    {
        messageVpn: messageVpn,
        auth: {username: solaceUser, password: solacePassword},
        destination: {topicName: "trip/flight/booked"}
    }
);

final solace:MessageProducer hotelBookedProducer = check new (
    solaceUrl,
    {
        messageVpn: messageVpn,
        auth: {username: solaceUser, password: solacePassword},
        destination: {topicName: "trip/hotel/booked"}
    }
);

final solace:MessageProducer carFailedProducer = check new (
    solaceUrl,
    {
        messageVpn: messageVpn,
        auth: {username: solaceUser, password: solacePassword},
        destination: {topicName: "trip/car/failed"}
    }
);

final solace:MessageProducer hotelCancelledProducer = check new (
    solaceUrl,
    {
        messageVpn: messageVpn,
        auth: {username: solaceUser, password: solacePassword},
        destination: {topicName: "trip/hotel/cancelled"}
    }
);
