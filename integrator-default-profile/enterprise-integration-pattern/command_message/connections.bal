import ballerina/http;

final http:Client slackClient = check new ("http://api.slack.com.balmock.io");
