import ballerinax/rabbitmq;
import ballerina/log;

listener rabbitmq:Listener rabbitmqListener = new (rabbitmqHost, rabbitmqPort);

@rabbitmq:ServiceConfig {
    queueName: queueName
}
service rabbitmq:Service on rabbitmqListener {
    remote function onMessage(RabbitMQAnydataMessage message, rabbitmq:Caller caller) returns error? {
        do {
            log:printInfo(message.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
