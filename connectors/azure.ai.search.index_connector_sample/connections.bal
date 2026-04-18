import ballerinax/azure.ai.search.index;

final index:Client indexClient = check new (string `${serviceUrl}`);
