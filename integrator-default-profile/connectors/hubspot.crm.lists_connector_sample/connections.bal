import ballerinax/hubspot.crm.lists;

final lists:Client listsClient = check new ({auth: {token: hubspotToken}});
