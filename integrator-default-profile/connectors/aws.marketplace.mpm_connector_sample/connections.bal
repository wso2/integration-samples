import ballerinax/aws.marketplace.mpm;

final mpm:Client mpmClient = check new ({
    auth: {
        accessKeyId: awsAccessKeyId,
        secretAccessKey: awsSecretAccessKey
    },
    region
});
