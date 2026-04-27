import ballerina/log;
import ballerinax/intercom;

public function main() returns error? {
    do {
        intercom:ContactWithPush result = check intercomClient->/contacts.post({email: contactEmail, role: "user"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
