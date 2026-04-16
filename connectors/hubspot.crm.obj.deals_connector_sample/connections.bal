import ballerinax/hubspot.crm.obj.deals;

final deals:Client dealsClient = check new ({auth: {token: hubspotToken}});
