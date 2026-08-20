import ballerina/log;

public function main() returns error? {
    do {
        check jmsMessageproducer->send({payload: "Hello from Solace JMS!"}, {topicName: solaceJmsTopicName});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
