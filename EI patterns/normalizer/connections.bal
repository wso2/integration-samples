import ballerina/http;

final http:Client zendeskClient = check new ("http://api.zendesk.com.balmock.io");
