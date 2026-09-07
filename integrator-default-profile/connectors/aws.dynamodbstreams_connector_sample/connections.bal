import ballerinax/aws.dynamodbstreams;

final dynamodbstreams:Client dynamodbstreamsClient = check new ({auth: {accessKeyId, secretAccessKey}, region});
