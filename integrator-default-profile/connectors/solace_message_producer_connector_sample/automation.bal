import ballerina/log;

public function main() returns error? {
    do {
        check solaceMessageproducer->send({payload: "Hello from Solace!"}, {topicName: solaceTopicName});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
