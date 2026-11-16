import ballerinax/googleapis.gmail;

final gmail:Client gmailClient = check new ({
    auth: {
        clientId: gmailClientId,
        clientSecret: gmailClientSecret,
        refreshToken: gmailRefreshToken
    }
});
