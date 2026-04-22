import ballerinax/salesforce;

final salesforce:Client salesforceClient = check new ({baseUrl: salesforceServiceUrl, auth: {token: salesforceToken}});
