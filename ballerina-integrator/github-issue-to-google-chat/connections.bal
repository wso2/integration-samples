import ballerina/http;

final http:Client gChatClient = check new ("https://chat.googleapis.com/v1/spaces");
