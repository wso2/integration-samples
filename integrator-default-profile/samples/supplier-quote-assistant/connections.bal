import ballerinax/googleapis.sheets;

configurable string sheetsClientId = ?;
configurable string sheetsClientSecret = ?;
configurable string sheetsRefreshToken = ?;
configurable string sheetsRefreshUrl = sheets:REFRESH_URL;

final sheets:Client budgetSheetsClient = check new ({
    auth: {
        clientId: sheetsClientId,
        clientSecret: sheetsClientSecret,
        refreshToken: sheetsRefreshToken,
        refreshUrl: sheetsRefreshUrl
    }
});

configurable string budgetSpreadsheetId = ?;
configurable string budgetSheetName = "Budgets";
