import ballerina/log;
import ballerinax/microsoft.outlook.mail;

public function main() returns error? {
    do {
        mail:MicrosoftGraphMessageCollectionResponse messages = check mailClient->listMessages();
        log:printInfo(messages.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
