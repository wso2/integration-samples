import ballerina/email;
import ballerina/log;

public function main() returns error? {
    do {
        check emailSmtpclient->sendMessage({to: "user@example.com", subject: "Hello from WSO2 Integrator", body: "This is a test email sent via the ballerinax/email SMTP connector."});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
