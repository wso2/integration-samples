import ballerinax/aws.ses;

final ses:Client sesClient = check new ({auth: {accessKeyId: accessKeyId, secretAccessKey: secretAccessKey}, region: region});
