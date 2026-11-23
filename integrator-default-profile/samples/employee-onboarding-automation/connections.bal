import ballerina/http;
import ballerinax/googleapis.gmail;
import ballerinax/googleapis.sheets;

final gmail:Client gmailClient = check new ({
    auth: {
        refreshToken: googleRefreshToken,
        clientId: googleClientId,
        clientSecret: googleClientSecret
    }
});

final sheets:Client sheetsClient = check new ({
    auth: {
        refreshUrl: "https://oauth2.googleapis.com/token",
        clientId: googleClientId,
        clientSecret: googleClientSecret,
        refreshToken: googleRefreshToken
    }
});

final http:Client pdfApiHubClient = check new ("https://pdfapihub.com");

// Asgardeo — SCIM 2.0 API with OAuth2 client credentials
final http:Client wso2IsClient = check new (
    string `https://api.asgardeo.io/t/${asgardeoOrg}`, {
        auth: {
            tokenUrl: string `https://api.asgardeo.io/t/${asgardeoOrg}/oauth2/token`,
            clientId: asgardeoClientId,
            clientSecret: asgardeoClientSecret,
            scopes: ["internal_user_mgt_create"]
        }
    }
);
