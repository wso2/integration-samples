import ballerina/http;

final http:Client iban = check new ("http://api.iban.com.balmock.io");
final http:Client intuit = check new ("http://api.intuit.com.balmock.io");
