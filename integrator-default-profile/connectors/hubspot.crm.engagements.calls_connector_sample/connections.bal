import ballerinax/hubspot.crm.engagements.calls;

final calls:Client callsClient = check new ({auth: {token: hubspotToken}}, string `${hubspotServiceUrl}`);
