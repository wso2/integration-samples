import ballerinax/salesforce;

// Initialize Salesforce client
final salesforce:Client salesforceClient = check new (config = {
    baseUrl: salesforceBaseUrl,
    auth: {
        token: salesforceAccessToken
    }
});
