import ballerinax/aws.s3;

final s3:Client s3Client = check new ({accessKeyId: accessKeyId, secretAccessKey: secretAccessKey, region: region});
