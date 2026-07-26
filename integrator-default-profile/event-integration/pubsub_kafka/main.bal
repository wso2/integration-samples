import ballerina/http;
import ballerina/log;
import ballerinax/kafka;

public type PageViewed record {|
    string userId;
    string url;
    string sessionId;
|};

listener kafka:Listener kafkaListener = new (bootstrapServers, {
    groupId: groupId,
    topics: [topicName]
});

service /publish on new http:Listener(8090) {
    resource function post pageview(PageViewed event) returns error? {
        check pageViewProducer->send({topic: topicName, value: event});
        log:printInfo("PageViewed event published", userId = event.userId, url = event.url);
    }
}

service kafka:Service on kafkaListener {
    remote function onConsumerRecord(PageViewed[] events) returns error? {
        foreach PageViewed event in events {
            log:printInfo("Updating recommendations", userId = event.userId, url = event.url);
        }
    }
}
