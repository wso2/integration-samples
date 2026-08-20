import ballerinax/aws.sqs;

listener sqs:Listener sqsListener = new (
    {
        region: sqs:US_EAST_1,
        auth: {
            accessKeyId: accessKeyId,
            secretAccessKey: secretAccessKey
        }
    },
    pollingConfig = {
        pollInterval: 5,
        waitTime: 20,
        visibilityTimeout: 30
    }
);
