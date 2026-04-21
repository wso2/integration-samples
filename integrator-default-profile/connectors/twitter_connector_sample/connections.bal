import ballerinax/twitter;

final twitter:Client twitterClient = check new ({auth: {token: twitterBearerToken}});
