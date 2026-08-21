import ballerina/io;
import ballerinax/aws.sqs;

listener sqs:Listener sqsListener = new ({region: "us-east-1", auth: {accessKeyId: string `${accessKeyId}`, secretAccessKey: string `${secretAccessKey}`}}, {pollInterval: 30, waitTime: 20, visibilityTimeout: 30});

@sqs:ServiceConfig {queueUrl: string `${queueUrl}`}
service sqs:Service on sqsListener {
    remote function onMessage(sqs:Message message) returns error? {
        do {
            S3Notification notification = check message.body.cloneWithType(S3Notification);
            io:println("New S3 events are received");
            foreach S3EventRecord eventRecord in notification.events {
                io:println(eventRecord);

            }
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
