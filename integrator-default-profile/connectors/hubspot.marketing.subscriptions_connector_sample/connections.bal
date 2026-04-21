import ballerinax/hubspot.marketing.subscriptions;

final subscriptions:Client subscriptionsClient = check new ({auth: {token: hubspotAuthToken}});
