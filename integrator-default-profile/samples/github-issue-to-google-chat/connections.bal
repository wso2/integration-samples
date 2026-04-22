import ballerina/http;
import ballerinax/trigger.github;

final http:Client gChatClient = check new ("https://chat.googleapis.com/v1/spaces");

listener github:Listener githubListener = new (listenerConfig = { webhookSecret: githubConfig.webhookSecret }, listenOn = 9090);
