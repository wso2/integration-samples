import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function post reminders(ReminderRequest request) returns error? {
        foreach Event event in request.events {
            foreach Attendee attendee in event.attendees {
                check sendReminder(attendee, event.eventName, request.date);
            }
        }
    }
}
