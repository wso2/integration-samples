import ballerina/log;
import ballerinax/openai.finetunes;

public function main() returns error? {
    do {
        finetunes:ListPaginatedFineTuningJobsResponse result = check finetunesClient->/fine_tuning/jobs.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
