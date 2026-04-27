import ballerina/log;
import ballerinax/mistral;

public function main() returns error? {
    do {
        mistral:ChatCompletionResponse result = check mistralClient->/chat/completions.post({messages: [{role: "user", content: "Hello, Mistral! What is the capital of France?"}], model: "mistral-small-latest"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
