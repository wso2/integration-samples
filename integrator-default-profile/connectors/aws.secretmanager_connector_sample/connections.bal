import ballerinax/aws.secretmanager;

final secretmanager:Client secretmanagerClient = check new (region = "us-east-1", auth = {accessKeyId: awsAccessKeyId, secretAccessKey: awsSecretAccessKey});
