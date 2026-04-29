import ballerina/log;
import ballerinax/googleapis.gmail;

public function main() returns error? {
    do {
        gmail:Message gmailMessage = check gmailClient->/users/[string `me`]/messages/send.post({to: ["recipient@example.com"], subject: "Hello from WSO2 Integrator", bodyInText: "This is a test email sent via the googleapis.gmail connector in WSO2 Integrator."});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
