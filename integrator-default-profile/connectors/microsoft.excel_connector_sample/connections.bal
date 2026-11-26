import ballerinax/microsoft.excel;

final excel:Client excelClient = check new ({auth: {clientId: excelClientId, clientSecret: excelClientSecret, refreshToken: excelRefreshToken, refreshUrl: excelRefreshUrl}}, string `${excelServiceUrl}`);
