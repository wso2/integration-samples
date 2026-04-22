import ballerina/log;
import ballerinax/aws.sns;

public function main() returns error? {
    do {
        sns:PublishMessageResponse publishResponse = check snsClient->publish("arn:aws:sns:us-east-1:123456789012:MyTopic", "Hello from WSO2 Integrator!");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
