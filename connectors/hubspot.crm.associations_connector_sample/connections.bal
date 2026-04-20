import ballerinax/hubspot.crm.associations;

final associations:Client associationsClient = check new ({auth: {token: hubspotAuthToken}});
