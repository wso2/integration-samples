import ballerinax/hubspot.crm.obj.leads;

final leads:Client leadsClient = check new ({auth: {token: hubspotAuthToken}});
