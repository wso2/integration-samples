import ballerinax/salesforce;

// Initialize Salesforce Client with OAuth 2.0
// Automatically refreshes access tokens when they expire
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        clientId: salesforceClientId,
        clientSecret: salesforceClientSecret,
        refreshToken: salesforceRefreshToken,
        refreshUrl: salesforceRefreshUrl
    }
});

// Note: QuickBooks HTTP Client is initialized in quickbooks_api.bal
// Both clients use OAuth 2.0 with automatic token refresh
//
// QuickBooks Base URL MUST be set in Config.toml:
// - Sandbox: https://sandbox-quickbooks.api.intuit.com/v3/company
// - Production: https://quickbooks.api.intuit.com/v3/company
