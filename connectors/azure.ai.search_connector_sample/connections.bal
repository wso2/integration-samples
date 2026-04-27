import ballerinax/azure.ai.search;

final search:Client searchClient = check new (string `${azureSearchServiceUrl}`);
