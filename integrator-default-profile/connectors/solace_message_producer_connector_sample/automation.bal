import ballerina/log;
import ballerinax/solace;

public function main() returns error? {
    do {
        var result = check solaceMessageproducer->send({payload: "Hello from Solace!"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
