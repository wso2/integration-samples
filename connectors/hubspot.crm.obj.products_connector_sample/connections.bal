import ballerinax/hubspot.crm.obj.products;

final products:Client productsClient = check new ({auth: {token: hubspotAuthToken}});
