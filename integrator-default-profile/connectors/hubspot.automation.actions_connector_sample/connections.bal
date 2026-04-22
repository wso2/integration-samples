import ballerinax/hubspot.automation.actions;

final actions:Client actionsClient = check new ({auth: {token: hubspotAuthToken}});
