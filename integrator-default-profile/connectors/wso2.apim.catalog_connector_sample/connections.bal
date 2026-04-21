import ballerinax/wso2.apim.catalog;

final catalog:Client catalogClient = check new ({auth: {username: apimUsername, password: apimPassword}});
