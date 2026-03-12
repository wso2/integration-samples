import ballerinax/hubspot.crm.obj.contacts;
import ballerinax/googleapis.sheets;

// Initialize HubSpot Contacts Client
final contacts:Client hubspotClient = check new (
    config = {
        auth: {
            token: hubspotAccessToken
        }
    }
);

// Initialize Google Sheets Client
final sheets:Client sheetsClient = check new (
    config = {
        auth: {
            clientId: googleClientId,
            clientSecret: googleClientSecret,
            refreshToken: googleRefreshToken,
            refreshUrl: googleRefreshUrl
        }
    }
);
