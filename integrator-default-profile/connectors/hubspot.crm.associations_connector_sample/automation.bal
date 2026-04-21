import ballerina/log;
import ballerinax/hubspot.crm.associations;

public function main() returns error? {
    do {
        associations:CollectionResponseMultiAssociatedObjectWithLabelForwardPaging result = check associationsClient->/objects/[string `contacts`]/[string `12345`]/associations/[string `companies`].get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
} 
