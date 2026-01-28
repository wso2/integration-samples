import ballerinax/salesforce;
import ballerinax/googleapis.sheets as sheets;

final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceConfig.baseUrl,
    auth: {
        clientId: salesforceConfig.clientId,
        clientSecret: salesforceConfig.clientSecret,
        refreshToken: salesforceConfig.refreshToken,
        refreshUrl: salesforceConfig.refreshUrl
    }
});

final sheets:Client sheetsClient = check new ({
    auth: {
        refreshToken: googleConfig.refreshToken,
        clientId: googleConfig.clientId,
        clientSecret: googleConfig.clientSecret,
        refreshUrl: sheets:REFRESH_URL
    }
});
