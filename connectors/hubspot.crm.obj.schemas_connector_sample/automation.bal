import ballerina/log;
import ballerinax/hubspot.crm.obj.schemas;

public function main() returns error? {
    do {
        schemas:CollectionResponseObjectSchemaNoPaging result = check schemasClient->/.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
