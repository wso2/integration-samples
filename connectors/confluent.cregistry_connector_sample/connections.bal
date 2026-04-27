import ballerinax/confluent.cregistry;

final cregistry:Client cregistryClient = check new (baseUrl = string `${cregistryServiceUrl}`);
