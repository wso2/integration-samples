import ballerinax/sap.commerce.webservices;

final webservices:Client webservicesClient = check new ({auth: {tokenUrl: sapCommerceTokenUrl, clientId: sapCommerceClientId, clientSecret: sapCommerceClientSecret}}, string `${sapCommerceServiceUrl}`);
