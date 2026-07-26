import ballerinax/rabbitmq;

final rabbitmq:Client thumbnailPublisher = check initPublisher();

function initPublisher() returns rabbitmq:Client|error {
    rabbitmq:Client cl = check new (
        host = rabbitmqHost, port = rabbitmqPort,
        username = rabbitmqUser, password = rabbitmqPassword
    );
    check cl->queueDeclare(queueName);
    return cl;
}
