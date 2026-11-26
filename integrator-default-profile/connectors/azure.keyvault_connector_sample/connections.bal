import ballerinax/azure.keyvault;

final keyvault:Client keyvaultClient = check new ({auth: {clientId: keyvaultClientId, clientSecret: keyvaultClientSecret, refreshToken: keyvaultRefreshToken, refreshUrl: keyvaultRefreshUrl, scopes: ["https://vault.azure.net/user_impersonation", "offline_access"]}}, string `${keyvaultServiceUrl}`);
