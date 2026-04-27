import ballerina/log;
import ballerinax/rabbitmq;

public function main() returns error? {
    do {
        check rabbitmqClient->publishMessage({content: "Hello, RabbitMQ!", routingKey: "myQueue"});
        log:printInfo("Message published successfully");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
