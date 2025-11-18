import ballerinax/salesforce;
import ballerinax/googleapis.sheets as sheets;

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
        refreshToken: googleRefreshToken,
        clientId: googleClientId,
        clientSecret: googleClientSecret,
        refreshUrl: sheets:REFRESH_URL
    }
});
