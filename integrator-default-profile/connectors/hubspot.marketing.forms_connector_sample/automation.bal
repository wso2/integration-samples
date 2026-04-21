import ballerina/log;
import ballerinax/hubspot.marketing.forms;

public function main() returns error? {
    do {
        forms:CollectionResponseFormDefinitionBaseForwardPaging formsResult = check formsClient->/.get();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
