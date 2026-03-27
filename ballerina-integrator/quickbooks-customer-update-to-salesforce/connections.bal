import ballerinax/salesforce;

// Initialize Salesforce Client with OAuth 2.0
// Automatically refreshes access tokens when they expire
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceConfig.baseUrl,
    auth: {
        clientId: salesforceConfig.clientId,
        clientSecret: salesforceConfig.clientSecret,
        refreshToken: salesforceConfig.refreshToken,
        refreshUrl: salesforceConfig.refreshUrl
    }
});


// QuickBooks Base URL MUST be set in Config.toml:
// - Sandbox: https://sandbox-quickbooks.api.intuit.com/v3/company

