import ballerinax/hubspot.crm.obj.contacts;

final contacts:Client contactsClient = check new ({auth: {token: hubspotToken}}, string `${hubspotServiceUrl}`);
