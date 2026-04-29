import ballerinax/hubspot.crm.commerce.orders;

final orders:Client ordersClient = check new ({auth: {token: hubspotAuthToken}});
