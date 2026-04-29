import ballerina/graphql;

final graphql:Client graphqlClient = check new (string `${graphqlServiceUrl}`, forwarded = string `${graphqlForwarded}`);
