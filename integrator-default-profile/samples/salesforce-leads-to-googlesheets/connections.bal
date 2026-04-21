import ballerinax/salesforce;
import ballerinax/googleapis.sheets;

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
        clientId: googleConfig.clientId,
        clientSecret: googleConfig.clientSecret,
        refreshToken: googleConfig.refreshToken,
        refreshUrl: sheets:REFRESH_URL
    }
});
