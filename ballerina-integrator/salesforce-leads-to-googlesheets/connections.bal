import ballerinax/salesforce;
import ballerinax/googleapis.sheets;

final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        clientId: salesforceClientId,
        clientSecret: salesforceClientSecret,
        refreshToken: salesforceRefreshToken,
        refreshUrl: salesforceRefreshUrl
    }
});

final sheets:Client sheetsClient = check new ({
    auth: {
        clientId: googleClientId,
        clientSecret: googleClientSecret,
        refreshToken: googleRefreshToken,
        refreshUrl: sheets:REFRESH_URL
    }
});
