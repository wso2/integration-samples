import ballerina/log;
import ballerinax/hubspot.automation.actions;

public function main() returns error? {
    do {
        actions:CollectionResponsePublicActionDefinitionForwardPaging result = check actionsClient->/[0].get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
