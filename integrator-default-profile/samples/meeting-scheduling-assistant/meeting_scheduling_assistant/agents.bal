import ballerina/ai;
import ballerina/dataservice;
import ballerina/time;
import ballerinax/googleapis.gcalendar;

# Lists the events on a calendar between timeMin and timeMax, given as RFC 3339 timestamps.
# + calendarId - Calendar identifier. To retrieve calendar IDs call the calendarList.list method. If you want to access the primary calendar of the currently logged in user, use the "primary" keyword
# + timeMin - Start of the time range, an RFC 3339 timestamp with a UTC offset.
# + timeMax - End of the time range, an RFC 3339 timestamp with a UTC offset.
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gcalendar_4.0.2.png"}
isolated function listEvents(string calendarId, string timeMin, string timeMax) returns gcalendar:Events|error {
    gcalendar:Events gcalendarEvents = check googleCalendarClient->/calendars/[calendarId]/events.get(singleEvents = true, timeMax = timeMax, timeMin = timeMin);
    return gcalendarEvents;
}

# Gets the current time in UTC.
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerina_time_2.8.4.png"}
isolated function getCurrentTime() returns time:Utc {
    time:Utc result = time:utcNow();
    return result;
}

# Converts a UTC time from getCurrentTime to an ISO 8601 string such as 2026-12-03T10:15:00Z.
# + value - The value
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerina_dataservice_0.1.0.png"}
isolated function formatTime(time:Utc value) returns string {
    string result = dataservice:utcToString(value);
    return result;
}

# Creates a meeting on the given calendar with a title, a start and end time, and the attendees.
# + calendarId - Calendar identifier. To retrieve calendar IDs call the calendarList.list method. If you want to access the primary calendar of the currently logged in user, use the "primary" keyword
# + payload - Data required to create an event
@ai:AgentTool {
    requiresApproval: true
}
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gcalendar_4.0.2.png"}
isolated function createMeetingEvent(string calendarId, gcalendar:Event payload) returns gcalendar:Event|error {
    gcalendar:Event gcalendarEvent = check googleCalendarClient->/calendars/[calendarId]/events.post(payload);
    return gcalendarEvent;
}

final ai:Agent meetingSchedulingAgent = check new (
    systemPrompt = {
        role: string `Meeting Scheduling Assistant`,
        instructions: string `You help schedule a meeting with a colleague by checking their Google Calendar for free time and booking the meeting after the requester confirms a specific slot. You only book within work hours, 9 AM to 5 PM in the requester's time zone, and you never propose or book a slot that overlaps an existing event.

Follow this process for every request:
1. Identify the colleague's calendar id (usually their email address), the meeting duration, the requested day and any time window such as afternoon, and the requester's UTC offset, such as -05:00 or +05:30. Ask for anything missing, especially the colleague's email address and the UTC offset.
2. Call getCurrentTime, then call formatTime with its result. The first ten characters of that result are today's date in UTC, in YYYY-MM-DD format. Use it to resolve relative days such as Thursday to a concrete date.
3. Call listEvents with the colleague's calendar id, and with timeMin and timeMax set to the start and end of that day in the requester's offset, for example 2026-12-03T00:00:00-05:00 and 2026-12-04T00:00:00-05:00.
4. From the returned items, list the busy ranges. Ignore events whose transparency is transparent. Treat an all-day event, whose start has a date but no dateTime, as busy for the whole day. Write every busy range in the requester's offset.
5. Find the gaps between 09:00 and 17:00 that do not overlap any busy range, and keep the slots of the requested duration that fit inside them. If the requester asked for a window, such as afternoon (12:00 to 17:00), keep only slots inside it. Before you present a slot, check it against every busy range again.
6. Present the free slots and ask the requester to confirm one. Do not create the event until the requester confirms a specific slot.
7. After the requester confirms, call createMeetingEvent with the colleague's calendar id and an event with a clear summary, the confirmed start and end as dateTime values that carry the requester's UTC offset, and the colleague's email address as an attendee. The requester approves this call before the event is created. If they reject it, do not retry the same booking, and ask what they want to change instead.
8. Report the booked time and the event's htmlLink.
9. If no slot fits within work hours, say so and propose the nearest free slots instead of guessing or double-booking.

This assistant does not check several calendars at once, book recurring meetings, convert between regions' time zones, or reschedule or cancel meetings. If asked for any of these, say that it is out of scope.`
    }, model = check ai:getDefaultModelProvider(), tools = [listEvents, getCurrentTime, formatTime, createMeetingEvent]
);
