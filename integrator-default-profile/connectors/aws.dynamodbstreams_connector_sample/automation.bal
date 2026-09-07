import ballerina/log;
import ballerinax/aws.dynamodbstreams;

public function main() returns error? {
    do {
        dynamodbstreams:StreamDescription streamDescription = check dynamodbstreamsClient->describeStream({streamArn});
        log:printInfo("Stream status: " + streamDescription.streamStatus.toString());

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
