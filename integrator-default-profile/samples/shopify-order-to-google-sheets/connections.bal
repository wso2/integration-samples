import ballerinax/googleapis.sheets;
import ballerinax/trigger.shopify;

listener shopify:Listener shopifyListener = new (listenerConfig, 9090);

final sheets:Client sheetsClient = check new ({
    auth: {
        clientId: googleSheetsConfig.clientId,
        clientSecret: googleSheetsConfig.clientSecret,
        refreshToken: googleSheetsConfig.refreshToken,
        refreshUrl: sheets:REFRESH_URL
    }
});
