import ballerinax/aws.sqs;

final sqs:Client sqsClient = check new ({
    auth: {
        accessKeyId,
        secretAccessKey
    },
    region
});
