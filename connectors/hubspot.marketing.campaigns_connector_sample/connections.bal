import ballerinax/hubspot.marketing.campaigns;

final campaigns:Client campaignsClient = check new ({auth: {token: hubspotBearerToken}});
