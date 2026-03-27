import ballerinax/googleapis.sheets;

final sheets:Client sheetsClient = check new ({
    auth: {
        clientId: googleSheetsConfig.clientId,
        clientSecret: googleSheetsConfig.clientSecret,
        refreshToken: googleSheetsConfig.refreshToken,
        refreshUrl: sheets:REFRESH_URL
    }
});
