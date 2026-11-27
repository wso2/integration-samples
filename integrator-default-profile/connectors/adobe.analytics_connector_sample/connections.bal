import ballerinax/adobe.analytics;

final analytics:Client analyticsClient = check new ({authorization: "Bearer " + analyticsAccessToken, xApiKey: analyticsApiKey}, serviceUrl = string `${analyticsServiceUrl}`);
