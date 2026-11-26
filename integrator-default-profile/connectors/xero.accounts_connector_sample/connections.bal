import ballerinax/xero.accounts;

final accounts:Client accountsClient = check new ({auth: {clientId: accountsClientId, clientSecret: accountsClientSecret, refreshToken: accountsRefreshToken, refreshUrl: accountsRefreshUrl}}, string `${accountsServiceUrl}`);
