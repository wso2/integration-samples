import ballerinax/hubspot.crm.associations.schema;

final schema:Client schemaClient = check new ({auth: {token: hubspotAuthToken}}, string `${hubspotServiceUrl}`);
