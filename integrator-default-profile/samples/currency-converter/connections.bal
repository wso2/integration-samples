import ballerina/http;

final http:Client httpClient = check new ("https://v6.exchangerate-api.com/v6/");
