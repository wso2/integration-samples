import ballerina/grpc;
import ballerina/log;

public function main() returns error? {
    do {
        [anydata, map<string|string[]>] result = check grpcClient->executeSimpleRPC("HelloWorld/hello", "Hello from WSO2 Integrator");
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
