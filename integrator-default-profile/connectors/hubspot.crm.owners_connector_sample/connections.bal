import ballerinax/hubspot.crm.owners;

final owners:Client ownersClient = check new ({auth: {token: hubspotToken}});
