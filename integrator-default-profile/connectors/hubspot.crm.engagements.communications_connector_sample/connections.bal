import ballerinax/hubspot.crm.engagements.communications;

final communications:Client communicationsClient = check new ({auth: {token: hubspotToken}});
