import ballerina/http;
import ballerinax/'client.config as clientConfig;

// Salesforce Configuration Record
public type SalesforceConfig record {|
    string baseUrl;
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshUrl;
|};

// Stripe Configuration Record
public type StripeConfig record {|
    string apiKey;
|};

// Sync Configuration Record
public type SyncConfig record {|
    SourceObject sourceObject = BOTH;
    MatchKey matchKey = EMAIL;
    boolean writeBackStripeId = true;
    string[] recordTypeFilter = [];
    string[] accountStatusFilter = [];
    boolean deleteStripeCustomerOnSalesforceDelete = true;
|};

// Salesforce Configuration
configurable SalesforceConfig salesforceConfig = ?;

// Stripe Configuration
configurable StripeConfig stripeConfig = ?;

// Sync Configuration
configurable SyncConfig syncConfig = {};

// Salesforce Auth Configuration
public function getSalesforceAuthConfig() returns clientConfig:OAuth2RefreshTokenGrantConfig => {
    refreshUrl: salesforceConfig.refreshUrl,
    refreshToken: salesforceConfig.refreshToken,
    clientId: salesforceConfig.clientId,
    clientSecret: salesforceConfig.clientSecret
};

// Stripe Auth Configuration
public function getStripeAuthConfig() returns http:BearerTokenConfig => {
    token: stripeConfig.apiKey
};
