import ballerinax/mailchimp.'transactional as mailchimp;
import ballerinax/salesforce;

final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceConfig.baseUrl,
    auth: {
        clientId: salesforceConfig.clientId,
        clientSecret: salesforceConfig.clientSecret,
        refreshToken: salesforceConfig.refreshToken,
        refreshUrl: salesforceConfig.refreshUrl
    }
});

final mailchimp:Client mailchimpClient = check new ({});
