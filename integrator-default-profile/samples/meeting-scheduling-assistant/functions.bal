import ballerina/ai;
import ballerina/time;
import ballerinax/googleapis.calendar;

final int workHoursStartHour = 9;
final int workHoursEndHour = 17;

# Lists a colleague's existing calendar events that fall within a given day, so free slots can be
# computed around them.
#
# + calendarId - the colleague's calendar id, typically their email address, or "primary" for the
# authenticated user's own calendar
# + dayStartDateTime - the start of the day to check, an RFC3339 timestamp (e.g. midnight of that day)
# + dayEndDateTime - the end of the day to check, an RFC3339 timestamp (e.g. midnight of the next day)
# + return - the busy time ranges found on that day, or an error if the calendar could not be read
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.calendar_4.0.0.png"}
isolated function listBusySlots(string calendarId, string dayStartDateTime, string dayEndDateTime) returns BusySlot[]|error {
    stream<calendar:Event, error?> events = check googleCalendarClient->getEvents(calendarId, filter = {
        timeMin: dayStartDateTime,
        timeMax: dayEndDateTime,
        singleEvents: true,
        orderBy: calendar:START_TIME
    });
    calendar:Event[] eventList = check from calendar:Event event in events
        select event;
    BusySlot[] busySlots = [];
    foreach calendar:Event event in eventList {
        calendar:Time? eventStart = event?.'start;
        calendar:Time? eventEnd = event?.end;
        if eventStart is calendar:Time && eventEnd is calendar:Time {
            string? startDateTime = eventStart.dateTime;
            string? endDateTime = eventEnd.dateTime;
            if startDateTime is string && endDateTime is string {
                busySlots.push({startDateTime: startDateTime, endDateTime: endDateTime});
            }
        }
    }
    return busySlots;
}

# Computes candidate free time slots of a given duration within work hours on a day, avoiding the
# given busy slots. This never proposes an overlapping or out-of-hours slot.
#
# + dayStartDateTime - the start of the day to check, an RFC3339 timestamp at local midnight
# + durationMinutes - the required meeting duration, in minutes
# + busySlots - the existing busy time ranges on that day to avoid
# + return - the free slots found within work hours, in order, or an error if the duration is not
# positive or a timestamp could not be parsed
@ai:AgentTool
isolated function findFreeSlots(string dayStartDateTime, int durationMinutes, BusySlot[] busySlots) returns FreeSlot[]|error {
    if durationMinutes <= 0 {
        return error("Meeting duration must be positive");
    }
    time:Utc dayStartUtc = check time:utcFromString(dayStartDateTime);
    time:Utc workStartUtc = time:utcAddSeconds(dayStartUtc, <time:Seconds>(workHoursStartHour * 3600));
    time:Utc workEndUtc = time:utcAddSeconds(dayStartUtc, <time:Seconds>(workHoursEndHour * 3600));
    time:Seconds durationSeconds = <time:Seconds>(durationMinutes * 60);

    [time:Utc, time:Utc][] busyRanges = [];
    foreach BusySlot busySlot in busySlots {
        time:Utc busyStart = check time:utcFromString(busySlot.startDateTime);
        time:Utc busyEnd = check time:utcFromString(busySlot.endDateTime);
        busyRanges.push([busyStart, busyEnd]);
    }

    FreeSlot[] freeSlots = [];
    time:Utc candidateStart = workStartUtc;
    while true {
        time:Utc candidateEnd = time:utcAddSeconds(candidateStart, durationSeconds);
        if candidateEnd > workEndUtc {
            break;
        }
        boolean overlaps = false;
        foreach [time:Utc, time:Utc] [busyStart, busyEnd] in busyRanges {
            if candidateStart < busyEnd && candidateEnd > busyStart {
                overlaps = true;
                break;
            }
        }
        if overlaps {
            candidateStart = time:utcAddSeconds(candidateStart, 900);
            continue;
        }
        freeSlots.push({
            startDateTime: time:utcToString(candidateStart),
            endDateTime: time:utcToString(candidateEnd)
        });
        candidateStart = time:utcAddSeconds(candidateStart, durationSeconds);
    }
    return freeSlots;
}

# Creates a new calendar event once a time slot has been confirmed by the requester. This writes
# to the calendar - only call it after the requester has confirmed a specific slot.
#
# + calendarId - the colleague's calendar id to create the event on, typically their email address
# + summary - the meeting title
# + startDateTime - the confirmed start time, an RFC3339 timestamp
# + endDateTime - the confirmed end time, an RFC3339 timestamp
# + timeZone - the IANA time zone of the start and end times, e.g. "America/New_York"
# + attendeeEmails - the email addresses of the attendees to invite
# + return - the booked meeting's details, or an error if the event could not be created
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.calendar_4.0.0.png"}
isolated function createMeetingEvent(string calendarId, string summary, string startDateTime, string endDateTime,
        string timeZone, string[] attendeeEmails) returns BookedMeeting|error {
    calendar:Attendee[] attendees = [];
    foreach string email in attendeeEmails {
        attendees.push({email: email});
    }
    calendar:InputEvent inputEvent = {
        summary: summary,
        'start: {dateTime: startDateTime, timeZone: timeZone},
        end: {dateTime: endDateTime, timeZone: timeZone},
        attendees: attendees
    };
    calendar:Event createdEvent = check googleCalendarClient->createEvent(calendarId, inputEvent);
    calendar:Time? confirmedStart = createdEvent?.'start;
    calendar:Time? confirmedEnd = createdEvent?.end;
    string? confirmedStartDateTime = confirmedStart is calendar:Time ? confirmedStart.dateTime : ();
    string? confirmedEndDateTime = confirmedEnd is calendar:Time ? confirmedEnd.dateTime : ();
    BookedMeeting result = {
        eventId: createdEvent.id,
        summary: createdEvent?.summary ?: summary,
        startDateTime: confirmedStartDateTime ?: startDateTime,
        endDateTime: confirmedEndDateTime ?: endDateTime,
        htmlLink: createdEvent?.htmlLink
    };
    return result;
}
