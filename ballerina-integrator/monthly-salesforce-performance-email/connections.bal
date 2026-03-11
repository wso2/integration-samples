import ballerinax/mailchimp.'transactional as mailchimp;
import ballerinax/salesforce;

final salesforce:Client salesforceClient = check new ({
    baseUrl: salesforceBaseUrl,
    auth: {
        clientId: salesforceClientId,
        clientSecret: salesforceClientSecret,
        refreshToken: salesforceRefreshToken,
        refreshUrl: salesforceRefreshUrl
    }
});

final mailchimp:Client mailchimpClient = check new ();
