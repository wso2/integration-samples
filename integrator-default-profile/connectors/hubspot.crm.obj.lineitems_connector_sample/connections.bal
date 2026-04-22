import ballerinax/hubspot.crm.obj.lineitems;

final lineitems:Client lineitemsClient = check new ({auth: {token: hubspotToken}});
