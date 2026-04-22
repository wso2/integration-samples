import ballerina/log;
import ballerinax/twilio;

public function main() returns error? {
    do {
        twilio:Message twilioMessage = check twilioClient->createMessage({To: "+15551234567", From: "+15550000000", Body: "Hello from WSO2 Integrator!"});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
