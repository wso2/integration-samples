import ballerinax/box;

final box:Client boxClient = check new ({auth: {clientId: boxClientId, clientSecret: boxClientSecret, refreshToken: boxRefreshToken, refreshUrl: boxRefreshUrl}}, string `${boxServiceUrl}`);
