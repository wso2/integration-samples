import ballerinax/hubspot.crm.obj.tickets;

final tickets:Client ticketsClient = check new ({auth: {token: hubspotAuthToken}});
