import ballerinax/hubspot.marketing.emails;

final emails:Client emailsClient = check new ({
    auth: {
        token: hubspotBearerToken
    }
}, string `${hubspotServiceUrl}`);
