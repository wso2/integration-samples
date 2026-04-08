import ballerinax/salesforce.marketingcloud;

final marketingcloud:Client marketingcloudClient = check new (string `${marketingCloudSubDomain}`, {
    auth: {
final marketingcloud:Client marketingcloudClient = check new (string `${marketingCloudSubDomain}`, {
    auth: {
        clientId: marketingCloudClientId,
        clientSecret: marketingCloudClientSecret
    }
});
    }
});
