import ballerinax/bitbucket;

final bitbucket:Client bitbucketClient = check new ({auth: {token: bitbucketAccessToken}}, string `${bitbucketServiceUrl}`);
