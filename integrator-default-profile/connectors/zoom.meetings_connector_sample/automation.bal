import ballerina/log;
import ballerinax/zoom.meetings;

public function main() returns error? {
    do {
        meetings:ListMeetingsResponse meetings = check meetingsClient->listMeetings(string `${meetingsUserId}`);
        log:printInfo(meetings.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
