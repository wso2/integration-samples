import ballerinax/hubspot.crm.engagements.tasks;

final tasks:Client tasksClient = check new ({auth: {token: hubspotAuthToken}}, string `${hubspotServiceUrl}`);
