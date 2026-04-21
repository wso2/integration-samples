import ballerina/http;

final http:Client shopify = check new ("http://BlackwellsBooks.myshopify.com.balmock.io");
final http:Client dhlExpress = check new ("http://express.api.dhl.com.balmock.io");
final http:Client fedEx = check new ("http://api.fedex.com.balmock.io");
final http:Client sendgrid = check new ("http://api.sendgrid.com.balmock.io");
