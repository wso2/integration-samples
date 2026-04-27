import ballerina/log;
import ballerinax/openai;

public function main() returns error? {
    do {
        openai:CreateChatCompletionResponse result = check openaiClient->/chat/completions.post({model: "gpt-4o", messages: [{role: "user", content: "Hello, OpenAI!"}]});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
