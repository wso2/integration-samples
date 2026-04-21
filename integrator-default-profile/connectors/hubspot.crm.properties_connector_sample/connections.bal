import ballerinax/hubspot.crm.properties;

final properties:Client propertiesClient = check new ({auth: {token: hubspotAuthToken}}, string `${hubspotServiceUrl}`);
