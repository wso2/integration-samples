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

// Salesforce listener configuration
final salesforce:ListenerConfig salesforceListenerConfig = {
    auth: {
        username: salesforceConfig.username,
        password: salesforceConfig.password
    }
};

// Salesforce Listener Configuration
listener salesforce:Listener salesforceListener = new (salesforceListenerConfig);
