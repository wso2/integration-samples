import ballerina/log;
import ballerinax/sap.signavio;

public function main() returns error? {
    do {
        signavio:DictionaryResponse[] categories = check signavioClient->listDictionaryCategories();
        log:printInfo(categories.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
