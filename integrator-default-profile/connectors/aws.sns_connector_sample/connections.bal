import ballerinax/aws.sns;

final sns:Client snsClient = check new ({
    auth: {
        accessKeyId: snsAccessKeyId,
        secretAccessKey: snsSecretAccessKey
    },
    region: snsRegion
});
