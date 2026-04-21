import ballerinax/hubspot.crm.obj.feedback;

final feedback:Client feedbackClient = check new ({auth: {token: hubspotToken}});
