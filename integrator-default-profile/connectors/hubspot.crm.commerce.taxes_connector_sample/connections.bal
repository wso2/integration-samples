import ballerinax/hubspot.crm.commerce.taxes;

final taxes:Client taxesClient = check new ({auth: {token: hubspotAuthToken}}, string `${hubspotServiceUrl}`);
