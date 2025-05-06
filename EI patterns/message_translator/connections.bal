import ballerina/http;

final http:Client quickBooks = check new ("http://api.quickbooks.com.balmock.io");
