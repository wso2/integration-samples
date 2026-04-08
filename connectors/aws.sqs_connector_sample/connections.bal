import ballerinax/aws.sqs;

final sqs:Client sqsClient = check new (region = "us-east-1", auth = {
    accessKeyId: sqsAccessKey,
    secretAccessKey: sqsSecretKey
});
