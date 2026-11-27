import ballerinax/xero.files;

final files:Client filesClient = check new ({auth: {clientId: filesClientId, clientSecret: filesClientSecret, refreshToken: filesRefreshToken, refreshUrl: filesRefreshUrl}}, string `${filesServiceUrl}`);
