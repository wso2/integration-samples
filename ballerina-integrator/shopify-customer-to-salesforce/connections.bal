import ballerinax/salesforce;

// Salesforce client initialization with OAuth2 refresh token grant
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceConfig.salesforceBaseUrl,
    auth: {
        clientId: salesforceConfig.salesforceClientId,
        clientSecret: salesforceConfig.salesforceClientSecret,
        refreshToken: salesforceConfig.salesforceRefreshToken,
        refreshUrl: salesforceConfig.salesforceRefreshUrl
    }
});
