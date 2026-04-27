import ballerina/log;
import ballerinax/azure.ai.search;

public function main() returns error? {
    do {
        search:ServiceStatistics result = check searchClient->getServiceStatistics(api\-version = "2023-11-01");
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
