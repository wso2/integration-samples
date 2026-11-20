import ballerina/ai;
import ballerina/time;
import ballerinax/googleapis.calendar;
import ballerinax/googleapis.chat;
import ballerinax/googleapis.gmail;
import ballerinax/googleapis.sheets;

# Reads every row of the Patients sheet: mobile number, name, email and date of birth.
# + return - Rows of the Patients sheet: mobile number, name, email and date of birth
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.sheets_4.0.0.png"}
isolated function readPatientRegister() returns sheets:Range|error {
    sheets:Range sheetsRange = check sheetsClient->getRange(clinicSpreadsheetId, "Patients", "A2:D");
    return sheetsRange;
}

# Registers a new patient by adding a row to the Patients sheet. values must be [mobile number in international format, full name, email or empty string, date of birth YYYY-MM-DD].
# + values - Array of values of the row to be added
# + return - The range the new patient row was added to
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.sheets_4.0.0.png"}
isolated function registerPatient((int|string|decimal|boolean|float)[] values) returns sheets:ValueRange|error {
    sheets:ValueRange sheetsValuerange = check sheetsClient->appendValue(clinicSpreadsheetId, values, {sheetName: "Patients"});
    return sheetsValuerange;
}

# Lists the events on the clinic calendar that overlap the time range timeMin to timeMax (RFC 3339 with offset, for example 2026-11-20T09:00:00+05:30). Each appointment event has the doctor ID, patient mobile, reason and booking reference in its description.
# + timeMax - End of the time range, RFC 3339 with offset, for example 2026-11-20T17:00:00+05:30
# + timeMin - Start of the time range, RFC 3339 with offset, for example 2026-11-20T09:00:00+05:30
# + return - The clinic calendar events in the range, earliest first
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.calendar_3.2.1.png"}
isolated function listClinicEvents(string timeMin, string timeMax) returns calendar:EventResponse|error {
    calendar:EventResponse calendarEventresponse = check calendarClient->getEventsResponse(clinicCalendarId, 250, filter = {timeMin: timeMin, timeMax: timeMax, singleEvents: true, orderBy: calendar:START_TIME});
    return calendarEventresponse;
}

# Books an appointment by creating a 30-minute event on the clinic calendar. summary: <patient name> with <doctor name>. description: doctor ID, patient mobile, reason and booking reference. startTime and endTime in RFC 3339 with offset, for example 2026-11-20T15:00:00+05:30. Returns the created event with its id.
# + event - Record that contains event information
# + return - The created calendar event, with its id
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.calendar_3.2.1.png"}
isolated function bookAppointmentEvent(calendar:InputEvent event) returns calendar:Event|error {
    calendar:Event calendarEvent = check calendarClient->createEvent(clinicCalendarId, event);
    return calendarEvent;
}

# Cancels an appointment by deleting its event from the clinic calendar. eventId is the id of the event returned by listClinicEvents or bookAppointmentEvent.
# + eventId - Event ID
# + return - An error if the event could not be deleted
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.calendar_3.2.1.png"}
isolated function cancelAppointmentEvent(string eventId) returns error? {
    check calendarClient->deleteEvent(clinicCalendarId, eventId);
}

# Emails a patient, for example a booking confirmation. payload: to (list with the patient email address), subject, and bodyInText (plain text signed with the clinic name).
# + payload - The message to be sent.
# + return - The sent Gmail message
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.2.0.png"}
isolated function emailPatient(gmail:MessageRequest payload) returns gmail:Message|error {
    gmail:Message gmailMessage = check gmailClient->/users/["me"]/messages/send.post(payload);
    return gmailMessage;
}

# Gets the current time as UTC seconds since the epoch. Pass the result to toCalendarDate to get the date, time and day of the week. The clinic is at UTC+05:30.
# + return - The current time in UTC
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerina_time_2.8.4.png"}
isolated function getCurrentTime() returns time:Utc {
    time:Utc result = time:utcNow();
    return result;
}

# Turns a UTC time from getCurrentTime into the clinic local date and time (UTC+05:30), with the day of the week.
# + utc - The UTC time as a tuple
# + return - The clinic local date, time and day of the week
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerina_time_2.8.4.png"}
isolated function toCalendarDate(time:Utc utc) returns time:Civil {
    time:Civil result = time:utcToCivil(time:utcAddSeconds(utc, 19800));
    return result;
}

# Posts a short alert to the front desk Google Chat space. Call it after every booking and cancellation, for example: New booking APT-1A2B3C: Nadeesha Wijesinghe with Dr. Maya Silva on 2026-11-20 15:00.
# + message - The alert text to post
# + return - The message posted in the front desk space
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.chat_0.1.1.png"}
isolated function notifyFrontDesk(string message) returns chat:Message|error {
    chat:Message chatMessage = check frontDeskChatClient->/spaces/[frontDeskSpaceId]/messages.post({text: message});
    return chatMessage;
}

final ai:Agent appointmentAgent = check new (
    systemPrompt = {
        role: string `Riverside Family Clinic Appointment Assistant`,
        instructions: string `You help patients of Riverside Family Clinic book, view, reschedule and cancel appointments over WhatsApp, Telegram or web chat. Times are in the clinic's local time (UTC+05:30).

Doctors (30-minute appointments):
- dr-perera: Dr. Anjali Perera, General practice, Monday to Friday 09:00-17:00
- dr-fernando: Dr. Ravi Fernando, Pediatrics, Monday, Wednesday, Friday and Saturday 08:00-13:00
- dr-silva: Dr. Maya Silva, Dermatology, Tuesday and Thursday 13:00-19:00

Conversation rules:
- Remember what the patient already told you. Never ask again for a detail they gave.
- Ask for all the details you still need in one message.
- Accept dates in any format and convert them yourself.

Identifying the patient:
- Ask for their mobile number and date of birth together. Read the Patients sheet (columns: mobile, name, email, date of birth) and find the row whose mobile number matches. The date of birth must match too. If it doesn't, say the details don't match and don't reveal anything.
- New patient: ask for full name, mobile number, date of birth and an optional email, then append a row to the Patients sheet.

Booking:
- Suggest a doctor based on the reason for the visit.
- List the clinic calendar events for the doctor's working hours on that day. A slot is free only if no event overlaps it and it is in the future. Offer at most five free slots.
- Book the slot the patient picks by creating a calendar event titled: <patient name> with <doctor name>. Put the doctor ID, mobile number, reason and a reference like APT-<6 random letters or digits> in the description.
- Give the reference. Email a confirmation if the patient has an email address.
- To reschedule, book the new slot first, then delete the old event.

Rules:
- Only work with the appointments of the patient you identified: their mobile number must be in the event description. Never reveal other patients' details.
- You don't give medical advice. For an emergency, tell the patient to call emergency services right away.
- Keep replies short and friendly, plain text, no tables. Reply in the patient's language.
- After every booking or cancellation, call notifyFrontDesk with one line: New booking or Cancelled, the reference, the patient name, the doctor and the time.
- Never book until the patient has picked one of the free slots you offered. Call getCurrentTime and toCalendarDate first, and never offer or book a date in the past.`
    }, memory = patientMemory, model = openaiModelprovider, tools = [readPatientRegister, registerPatient, listClinicEvents, bookAppointmentEvent, cancelAppointmentEvent, emailPatient, getCurrentTime, toCalendarDate, notifyFrontDesk]
);
final ai:InMemoryShortTermMemoryStore patientMemoryStore = check new (100);
final ai:ShortTermMemory patientMemory = check new (patientMemoryStore);
final ai:Agent frontDeskAgent = check new (
    systemPrompt = {
        role: string `Riverside Family Clinic Front Desk Assistant`,
        instructions: string `You assist the front desk staff of Riverside Family Clinic in Google Chat. Times are in the clinic's local time (UTC+05:30). Use getCurrentTime and toCalendarDate to turn words like today or tomorrow into dates.

Doctors (30-minute appointments):
- dr-perera: Dr. Anjali Perera, General practice, Monday to Friday 09:00-17:00
- dr-fernando: Dr. Ravi Fernando, Pediatrics, Monday, Wednesday, Friday and Saturday 08:00-13:00
- dr-silva: Dr. Maya Silva, Dermatology, Tuesday and Thursday 13:00-19:00

You can:
- Show the schedule for a day or a doctor: list the clinic calendar events for that day.
- Find free slots, and book or cancel appointments for patients who call or walk in. Staff confirm the patient's identity in person, so you don't need a date of birth. Register new patients in the Patients sheet.
- Email patients, for example when a doctor is running late. Look up the email address in the Patients sheet. Say a patient was emailed only when the email tool succeeds; otherwise tell the staff which patients to call.

Remember what the staff member already told you and ask for missing details in one message. Be concise. When listing a schedule, show one line per appointment: time, patient, doctor, reason and reference.
After you book or cancel for a patient, call notifyFrontDesk with one line: New booking or Cancelled, the reference, the patient name, the doctor and the time.`
    }, memory = frontDeskMemory, model = openaiModelprovider, tools = [readPatientRegister, listClinicEvents, cancelAppointmentEvent, getCurrentTime, notifyFrontDesk, registerPatient, bookAppointmentEvent, emailPatient, toCalendarDate]
);
final ai:InMemoryShortTermMemoryStore frontDeskMemoryStore = check new (100);
final ai:ShortTermMemory frontDeskMemory = check new (frontDeskMemoryStore);
