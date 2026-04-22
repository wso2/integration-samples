import ballerina/log;
import ballerinax/hubspot.crm.lists;

public function main() returns error? {
    do {
        lists:ListsByIdResponse result = check listsClient->getGetAll();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
