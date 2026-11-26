import ballerinax/microsoft.dynamics365.bc;

final bc:Client bcClient = check new ({auth: {clientId: bcClientId, clientSecret: bcClientSecret, refreshToken: bcRefreshToken, refreshUrl: bcRefreshUrl, scopes: ["https://api.businesscentral.dynamics.com/Financials.ReadWrite.All", "offline_access"]}}, string `${bcServiceUrl}`);
