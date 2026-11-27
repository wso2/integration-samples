import ballerinax/xero.finance;

final finance:Client financeClient = check new ({auth: {clientId: financeClientId, clientSecret: financeClientSecret, refreshToken: financeRefreshToken, refreshUrl: financeRefreshUrl}}, string `${financeServiceUrl}`);
