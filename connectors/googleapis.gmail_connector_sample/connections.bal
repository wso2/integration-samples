import ballerinax/googleapis.gmail;

final gmail:Client gmailClient = check new ("{ auth: { refreshUrl: gmailRefreshUrl, refreshToken: gmailRefreshToken, clientId: gmailClientId, clientSecret: gmailClientSecret } }");
