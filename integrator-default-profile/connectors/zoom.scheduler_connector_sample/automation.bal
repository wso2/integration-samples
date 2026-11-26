import ballerina/log;
import ballerinax/zoom.scheduler;

public function main() returns error? {
    do {
        scheduler:ScheduleList schedules = check schedulerClient->listSchedules();
        log:printInfo(schedules.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
