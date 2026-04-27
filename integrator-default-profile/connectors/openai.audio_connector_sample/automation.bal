import ballerina/log;
import ballerinax/openai.audio;

public function main() returns error? {
    do {
        audio:CreateTranscriptionResponseJson|audio:CreateTranscriptionResponseVerboseJson result = check audioClient->/audio/transcriptions.post({
            file: {
                fileContent: [],
                fileName: ""
            },
            model: "whisper-1"
        });
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
