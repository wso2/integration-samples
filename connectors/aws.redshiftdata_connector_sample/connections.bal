import ballerinax/aws.redshiftdata;

final redshiftdata:Client redshiftdataClient = check new (region = "us-east-1", auth = {accessKeyId: awsAccessKeyId, secretAccessKey: awsSecretAccessKey, sessionToken: awsSessionToken});
