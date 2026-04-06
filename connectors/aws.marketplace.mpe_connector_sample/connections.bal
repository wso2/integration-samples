import ballerinax/aws.marketplace.mpe;

final mpe:Client mpeClient = check new (region = <mpe:Region>awsRegion, auth = "{accessKeyId: awsAccessKeyId, secretAccessKey: awsSecretAccessKey}");
