import ballerina/log;
import ballerinax/gcloud.pubsub;

public function main() returns error? {
    do {
        string result = check pubsubPublisher->publish({data: pubsubMessagePayload.toBytes()});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
