import ballerina/log;
import ballerinax/zoom.scheduler;

public function main() returns error? {
    do {
        scheduler:InlineResponse2005 schedulerInlineresponse2005 = check zoomSchedulerClient->/schedules.get();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
