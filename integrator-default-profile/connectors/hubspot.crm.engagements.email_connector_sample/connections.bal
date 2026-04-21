import ballerinax/hubspot.crm.engagements.email;

final email:Client emailClient = check new ({auth: {token: hubspotToken}});
