import ballerina/log;
import ballerinax/aws.sqs;

public function main() returns error? {
    do {
        sqs:SendMessageResponse sqsSendmessageresponse = check sqsClient->sendMessage("https://sqs.us-east-1.amazonaws.com/123456789012/MyQueue", "Hello from WSO2 Integrator!");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
