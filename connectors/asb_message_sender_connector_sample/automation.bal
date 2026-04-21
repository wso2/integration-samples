import ballerina/log;
import ballerinax/asb;

public function main() returns error? {
    do {
        asb:Error? result = asbMessagesender->send({body: "Hello from WSO2 Integrator — ASB MessageSender".toBytes(), contentType: "application/json", label: "IntegrationTest"});

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
