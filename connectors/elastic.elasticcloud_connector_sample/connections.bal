import ballerinax/elastic.elasticcloud;

final elasticcloud:Client elasticcloudClient = check new ({authorization: elasticApiKey}, serviceUrl = string `${elasticServiceUrl}`);
