import ballerinax/hubspot.crm.commerce.discounts;

final discounts:Client discountsClient = check new ({auth: {token: hubspotAuthToken}}, string `${hubspotServiceUrl}`);
