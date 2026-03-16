import ballerinax/salesforce;
import ballerinax/'client.config as clientConfig;
import ballerinax/docusign.dsesign;

// Salesforce OAuth configuration for client
final clientConfig:OAuth2RefreshTokenGrantConfig salesforceOAuthConfig = {
    clientId: salesforceConfig.clientId,
    clientSecret: salesforceConfig.clientSecret,
    refreshToken: salesforceConfig.refreshToken,
    refreshUrl: salesforceConfig.refreshUrl
};

// Salesforce Client Configuration
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceConfig.baseUrl,
    auth: salesforceOAuthConfig
});

// DocuSign Client Configuration
final dsesign:Client docusignClient = check new (
    config = {
        auth: {
            clientId: docusignConfig.clientId,
            clientSecret: docusignConfig.clientSecret,
            refreshToken: docusignConfig.refreshToken,
            refreshUrl: docusignConfig.refreshUrl
        }
    },
    serviceUrl = docusignConfig.baseUrl
);

// Salesforce Listener Configuration
// The listener requires username/password authentication for CometD protocol
// If SOAP API is disabled, you need to enable it in Salesforce Setup or use an alternative approach
listener salesforce:Listener salesforceListener = new ({
    auth: {
        username: salesforceConfig.username,
        password: salesforceConfig.password
    }
});
