import ballerinax/aws.secretmanager;

final secretmanager:Client secretmanagerClient = check new (auth = {accessKeyId: accessKeyId, secretAccessKey: secretAccessKey}, region = region);
