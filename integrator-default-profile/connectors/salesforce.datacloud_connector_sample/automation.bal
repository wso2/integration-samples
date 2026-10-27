import ballerina/log;
import ballerinax/salesforce.datacloud;

public function main() returns error? {
    do {
        datacloud:MetadataResponse result = check datacloudClient->listProfileMetadata();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
