import ballerina/log;
import ballerinax/mongodb;

public function main() returns error? {
    do {
        mongodb:Database mongodbDatabase = check mongodbClient->getDatabase("hrdb");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
