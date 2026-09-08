import ballerinax/aws.simpledb;

final simpledb:Client simpledbClient = check new ({auth: {accessKeyId, secretAccessKey}, region});
