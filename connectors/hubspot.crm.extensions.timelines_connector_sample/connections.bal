import ballerinax/hubspot.crm.extensions.timelines;

final timelines:Client timelinesClient = check new ({auth: {token: hubspotAuthToken}});
