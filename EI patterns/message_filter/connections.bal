import ballerina/http;

final http:Client notificationChannel = check new ("http://api.notification.channel.com.balmock.io");
