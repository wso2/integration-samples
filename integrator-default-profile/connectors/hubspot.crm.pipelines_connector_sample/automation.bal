import ballerina/log;
import ballerinax/hubspot.crm.pipelines;

public function main() returns error? {
    do {
        pipelines:CollectionResponsePipelineNoPaging result = check pipelinesClient->/[string `deals`].get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
