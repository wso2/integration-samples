import ballerinax/nats;

final nats:Client natsClient = check new (string `${natsUrl}`);
