import ballerina/log;
import ballerinax/hubspot.crm.properties;

public function main() returns error? {
    do {
        properties:CollectionResponsePropertyNoPaging result = check propertiesClient->/[string `contacts`].get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
