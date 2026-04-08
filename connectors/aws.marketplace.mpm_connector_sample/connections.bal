import ballerinax/aws.marketplace.mpm;

final mpm:Client mpmClient = check new (region = "us-east-1", auth = {
    accessKeyId: awsAccessKeyId,
    secretAccessKey: awsSecretAccessKey
});
