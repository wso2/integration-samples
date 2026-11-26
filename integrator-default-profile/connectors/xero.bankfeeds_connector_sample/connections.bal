import ballerinax/xero.bankfeeds;

final bankfeeds:Client bankfeedsClient = check new ({auth: {clientId: bankfeedsClientId, clientSecret: bankfeedsClientSecret, refreshToken: bankfeedsRefreshToken, refreshUrl: bankfeedsRefreshUrl}}, string `${bankfeedsServiceUrl}`);
