import ballerinax/salesforce.datacloud;

final datacloud:Client datacloudClient = check new ({auth: {clientId: datacloudClientId, clientSecret: datacloudClientSecret}}, string `${datacloudOrgUrl}`);
