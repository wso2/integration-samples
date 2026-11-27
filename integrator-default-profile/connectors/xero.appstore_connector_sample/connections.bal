import ballerinax/xero.appstore;

final appstore:Client appstoreClient = check new ({auth: {clientId: appstoreClientId, clientSecret: appstoreClientSecret, tokenUrl: appstoreTokenUrl, scopes: ["marketplace.billing"]}}, string `${appstoreServiceUrl}`);
