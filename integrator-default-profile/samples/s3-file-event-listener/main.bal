import ballerina/io;
import ballerinax/aws.sqs;

@sqs:ServiceConfig {queueUrl}
service sqs:Service on sqsListener {
    remote function onMessage(sqs:Message message) returns error? {
        do {
            S3Notification notification = check message.body.cloneWithType(S3Notification);
            foreach S3EventRecord eventRecord in notification.Records {
                io:println(string `bucket=${eventRecord.s3.bucket.name} key=${eventRecord.s3.'object.key} size=${eventRecord.s3.'object.size}`);
            }
        } on fail error err {
            return error("unhandled error", err);
        }
    }
}
