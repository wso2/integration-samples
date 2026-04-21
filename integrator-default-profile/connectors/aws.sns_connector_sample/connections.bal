import ballerinax/aws.sns;

final sns:Client snsClient = check new ({accessKeyId: snsAccessKeyId, secretAccessKey: snsSecretAccessKey, securityToken: snsSecurityToken, region: snsRegion});
