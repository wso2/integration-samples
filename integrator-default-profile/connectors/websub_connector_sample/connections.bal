import ballerina/websubhub;

final websubhub:PublisherClient websubhubPublisherclient = check new (string `${websubHubUrl}`);
