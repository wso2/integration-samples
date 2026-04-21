import ballerinax/hubspot.crm.obj.schemas;

final schemas:Client schemasClient = check new ({auth: {token: hubspotAuthToken}}, string `${hubspotServiceUrl}`);
