import ballerinax/hubspot.marketing.forms;

final forms:Client formsClient = check new ({auth: {token: hubspotBearerToken}});
