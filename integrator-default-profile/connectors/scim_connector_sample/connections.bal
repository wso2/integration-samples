import ballerinax/scim;

final scim:Client scimClient = check new ({auth: {tokenUrl: scimTokenUrl, clientId: scimClientId, clientSecret: scimClientSecret}}, string `${scimServiceUrl}`);
