import ballerinax/googleapis.sheets;

final sheets:Client budgetSheetsClient = check new ({
    auth: {
        refreshToken: sheetsRefreshToken,
        clientId: sheetsClientId,
        clientSecret: sheetsClientSecret
    }
});
