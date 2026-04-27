import ballerina/log;
import ballerinax/azure.ai.search.index;

public function main() returns error? {
    do {
        index:IndexDocumentsResult result = check indexClient->documentsIndex({value: []}, api\-version = "2024-07-01");
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
