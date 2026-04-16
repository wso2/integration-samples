import ballerina/log;
import ballerinax/hubspot.crm.obj.contacts;

public function main() returns error? {
    do {
        contacts:SimplePublicObject result = check contactsClient->/.post({properties: {"email": "john.doe@example.com", "firstname": "John", "lastname": "Doe", "phone": "555-1234"}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
