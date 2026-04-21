import ballerinax/hubspot.crm.engagement.meeting;

final meeting:Client meetingClient = check new ({auth: {token: hubspotAuthToken}});
