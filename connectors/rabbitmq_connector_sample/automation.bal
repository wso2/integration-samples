import ballerina/log;
import ballerinax/rabbitmq;

public function main() returns error? {
    do {
        rabbitmq:Error? result = rabbitmqClient->publishMessage({content: "Hello, RabbitMQ!", routingKey: "myQueue"});
        log:printInfo(result.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
