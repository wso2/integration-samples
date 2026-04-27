import ballerina/websocket;

final websocket:Client websocketClient = check new (string `${websocketServiceUrl}`);
