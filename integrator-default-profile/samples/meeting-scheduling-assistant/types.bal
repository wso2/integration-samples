# An existing event's busy time range on a calendar, used to compute free slots.
#
# + startDateTime - the event's start time, an RFC3339 timestamp
# + endDateTime - the event's end time, an RFC3339 timestamp
public type BusySlot record {|
    string startDateTime;
    string endDateTime;
|};

# A candidate free time slot within work hours.
#
# + startDateTime - the slot's start time, an RFC3339 timestamp
# + endDateTime - the slot's end time, an RFC3339 timestamp
public type FreeSlot record {|
    string startDateTime;
    string endDateTime;
|};

# The result of creating a calendar event.
#
# + eventId - the id of the created event
# + summary - the event title
# + startDateTime - the event's confirmed start time, an RFC3339 timestamp
# + endDateTime - the event's confirmed end time, an RFC3339 timestamp
# + htmlLink - a link to view the event, if available
public type BookedMeeting record {|
    string eventId;
    string summary;
    string startDateTime;
    string endDateTime;
    string htmlLink?;
|};
