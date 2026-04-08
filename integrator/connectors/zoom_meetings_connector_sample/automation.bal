import ballerina/log;
import ballerinax/zoom.meetings;

public function main() returns error? {
    do {
        meetings:InlineResponse20028 meetingsList = check meetingsClient->/users/[string `me`]/meetings.get();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
