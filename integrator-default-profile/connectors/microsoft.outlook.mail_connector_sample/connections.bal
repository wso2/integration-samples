import ballerinax/microsoft.outlook.mail;

final mail:Client mailClient = check new ({auth: {clientId: mailClientId, clientSecret: mailClientSecret, refreshToken: mailRefreshToken, refreshUrl: mailRefreshUrl}}, string `${mailServiceUrl}`);
