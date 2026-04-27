import ballerina/log;
import ballerinax/asb;

public function main() returns error? {
    do {
        json payload = {message: "Hello from WSO2 Integrator — ASB MessageSender"};
        asb:Error? result = asbMessagesender->send({body: payload.toJsonString().toBytes(), contentType: "application/json", label: "IntegrationTest"});

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
