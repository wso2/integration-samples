import ballerinax/aws.dynamodb;

final dynamodb:Client dynamodbClient = check new ({auth: {accessKeyId: accessKeyId, secretAccessKey: secretAccessKey}, region: region});
