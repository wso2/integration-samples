import ballerinax/googleapis.gmail;

final gmail:Client gmailClient = check new ({auth: {clientId, clientSecret, refreshToken}});

