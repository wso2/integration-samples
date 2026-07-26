import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
import ballerinax/rabbitmq;

final postgresql:Client usersDb = check new (dbHost, dbUser, dbPassword, dbName, dbPort);

final rabbitmq:Client rabbitmqClient = check initRabbitMq();

function initRabbitMq() returns rabbitmq:Client|error {
    rabbitmq:Client cl = check new (rabbitmqHost, rabbitmqPort);
    check cl->exchangeDeclare(rabbitmqExchange, rabbitmq:DIRECT_EXCHANGE);
    return cl;
}
