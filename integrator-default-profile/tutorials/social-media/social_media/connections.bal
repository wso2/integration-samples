import social_media.socialmedia;

import ballerina/http;
import ballerinax/rabbitmq;

final socialmedia:Client dbClient = check new (dbClientHost, dbClientPort, dbClientUser, dbClientPassword, dbClientDatabase);
final rabbitmq:Client rabbitmqClient = check new (rabbitmqHost, rabbitmqPort);
final http:Client sentimentClient = check new ("http://localhost:9000/text-processing");
