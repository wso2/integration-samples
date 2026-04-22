import ballerinax/hubspot.crm.obj.companies;

final companies:Client companiesClient = check new ({auth: {token: hubspotToken}});
