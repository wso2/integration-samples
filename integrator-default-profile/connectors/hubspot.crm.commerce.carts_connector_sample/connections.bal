import ballerinax/hubspot.crm.commerce.carts;

final carts:Client cartsClient = check new ({auth: {token: hubspotAuthToken}});
