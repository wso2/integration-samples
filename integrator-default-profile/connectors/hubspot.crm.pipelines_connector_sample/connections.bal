import ballerinax/hubspot.crm.pipelines;

final pipelines:Client pipelinesClient = check new ({auth: {token: hubspotAuthToken}}, string `${hubspotServiceUrl}`);
