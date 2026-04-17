import ballerina/log;
import ballerinax/hubspot.crm.obj.feedback;

public function main() returns error? {
    do {
        feedback:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging result = check feedbackClient->/.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
