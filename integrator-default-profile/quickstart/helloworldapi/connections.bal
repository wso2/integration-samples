import ballerina/http;

final http:Client externalApi = check new ("https://apis.wso2.com/zvdz/mi-qsg/v1.0");
