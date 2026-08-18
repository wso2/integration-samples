import ballerina/http;
import ballerina/lang.runtime;
import ballerina/log;
import ballerinax/rabbitmq;

public type ResizeJob record {
    string imageId;
    string sourceUrl;
};

listener rabbitmq:Listener rabbitmqListener = new (rabbitmqHost, rabbitmqPort,
    username = rabbitmqUser,
    password = rabbitmqPassword
);

service /jobs on new http:Listener(httpPort) {
    resource function post resize(ResizeJob job) returns error? {
        check thumbnailPublisher->publishMessage({
            content: job.toJsonString().toBytes(),
            routingKey: queueName
        });
        log:printInfo("Resize job queued", imageId = job.imageId);
    }
}

@rabbitmq:ServiceConfig {queueName: queueName}
service rabbitmq:Service on rabbitmqListener {
    remote function onMessage(ResizeJob job) returns error? {
        log:printInfo("Generating thumbnail (start)", imageId = job.imageId, sourceUrl = job.sourceUrl);
        runtime:sleep(2);
        log:printInfo("Thumbnail ready", imageId = job.imageId);
    }
}
