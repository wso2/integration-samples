import ballerina/log;
import ballerinax/hubspot.crm.engagement.meeting;

public function main() returns error? {
    do {
        meeting:SimplePublicObject result = check meetingClient->/.post({associations: [], properties: {"hs_meeting_title": "Team Meeting", "hs_timestamp": "1700000000000", "hs_meeting_outcome": "SCHEDULED"}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
