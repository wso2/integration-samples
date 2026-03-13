import ballerinax/salesforce;
import ballerinax/'client.config as clientConfig;
import ballerinax/docusign.dsesign;

// Salesforce Client Configuration
final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: salesforceOAuthConfig
});

// DocuSign Client Configuration
final dsesign:Client docusignClient = check new (
    config = {
        auth: {
            clientId: docusignClientId,
            clientSecret: docusignClientSecret,
            refreshToken: docusignRefreshToken,
            refreshUrl: docusignRefreshUrl
        }
    },
    serviceUrl = docusignBaseUrl
);

// Salesforce base URL
configurable string salesforceBaseUrl = "https://login.salesforce.com";

// Salesforce OAuth configuration for client
configurable string salesforceClientId = ?;
configurable string salesforceClientSecret = ?;
configurable string salesforceRefreshToken = ?;
configurable string salesforceRefreshUrl = "https://login.salesforce.com/services/oauth2/token";

final clientConfig:OAuth2RefreshTokenGrantConfig salesforceOAuthConfig = {
    clientId: salesforceClientId,
    clientSecret: salesforceClientSecret,
    refreshToken: salesforceRefreshToken,
    refreshUrl: salesforceRefreshUrl
};

// Salesforce listener configuration
final salesforce:ListenerConfig salesforceListenerConfig = {
    auth: {
        username: salesforceUsername,
        password: salesforcePassword
    }
};

// Salesforce Listener Configuration
listener salesforce:Listener salesforceListener = new (salesforceListenerConfig);
