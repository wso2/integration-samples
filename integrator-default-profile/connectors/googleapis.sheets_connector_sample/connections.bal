import ballerinax/googleapis.sheets;

final sheets:Client sheetsClient = check new ({auth: {clientId: sheetsClientId, clientSecret: sheetsClientSecret, refreshToken: sheetsRefreshToken, refreshUrl: sheetsRefreshUrl}});
