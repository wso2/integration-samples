import ballerina/log;
import ballerinax/milvus;

public function main() returns error? {
    do {
        var result = check milvusClient->upsert({collectionName: "demo_collection", data: {vectors: [0.1, 0.2, 0.3]}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
