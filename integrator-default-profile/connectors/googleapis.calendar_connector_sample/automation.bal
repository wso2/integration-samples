import ballerina/log;
import ballerinax/googleapis.calendar;

public function main() returns error? {
    do {
        calendar:Event calendarEvent = check calendarClient->createEvent("primary", {summary: "Team Meeting", 'start: {dateTime: "2025-12-01T10:00:00Z", timeZone: "UTC"}, end: {dateTime: "2025-12-01T11:00:00Z", timeZone: "UTC"}});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
