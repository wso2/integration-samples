import ballerinax/github;
import ballerinax/googleapis.gmail;

final github:Client githubClient = check new ({
    auth: {token: githubToken}
});

final gmail:Client gmailClient = check new ({
    auth: {
        clientId: gmailClientId,
        clientSecret: gmailClientSecret,
        refreshToken: gmailRefreshToken,
        refreshUrl: gmailRefreshUrl
    }
});
