import ballerinax/googleapis.sheets;

final sheets:Client sheetsClient = check new ({
    auth: {
        clientId: googleClientID,
        clientSecret: googleClientSecret,
        refreshUrl: googleRefreshURL,
        refreshToken: googleRefreshToken
    }
});

