import ballerinax/aws.redshiftdata;

final redshiftdata:Client redshiftdataClient = check new (region = awsRegion, auth = {accessKeyId: awsAccessKeyId, secretAccessKey: awsSecretAccessKey, sessionToken: awsSessionToken});
