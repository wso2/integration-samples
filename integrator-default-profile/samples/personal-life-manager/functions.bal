import ballerina/ai;
import ballerina/time;
import ballerinax/googleapis.gmail;
import ballerinax/googleapis.calendar;
import ballerinax/googleapis.tasks as gtasks;

@ai:AgentTool
isolated function getUnreadEmails() returns string|error {
    gmail:ListMessagesResponse messageList = check gmailClient->/users/me/messages(
        q = "label:INBOX is:unread",
        maxResults = 10
    );
    gmail:Message[] messages = messageList.messages ?: [];
    if messages.length() == 0 {
        return "No unread emails found.";
    }
    string[] summaries = [];
    foreach gmail:Message msg in messages {
        string msgId = msg.id;
        gmail:Message full = check gmailClient->/users/me/messages/[msgId](format = "metadata");
        string sender = full.'from ?: "";
        string subject = full.subject ?: "";
        string snippet = full.snippet ?: "";
        summaries.push(string `From: ${sender} | Subject: ${subject} | ${snippet}`);
    }
    return string:'join("\n", ...summaries);
}

@ai:AgentTool
isolated function getCalendarEvents(string date = "") returns string|error {
    // Shift UTC time by the configured offset to get the user's local date
    time:Civil local = time:utcToCivil(time:utcAddSeconds(time:utcNow(), <decimal>(calendarTimeZone * 60)));
    string month = local.month < 10 ? string `0${local.month}` : local.month.toString();
    string day = local.day < 10 ? string `0${local.day}` : local.day.toString();
    string targetDate = date.length() > 0 ? date : string `${local.year}-${month}-${day}`;

    int absOffset = calendarTimeZone < 0 ? -calendarTimeZone : calendarTimeZone;
    string sign = calendarTimeZone >= 0 ? "+" : "-";
    string offsetH = (absOffset / 60 < 10 ? "0" : "") + (absOffset / 60).toString();
    string offsetM = (absOffset % 60 < 10 ? "0" : "") + (absOffset % 60).toString();
    string offsetStr = sign + offsetH + ":" + offsetM;

    string timeMin = string `${targetDate}T00:00:00${offsetStr}`;
    string timeMax = string `${targetDate}T23:59:59${offsetStr}`;

    calendar:EventFilterCriteria filter = {
        timeMin: timeMin,
        timeMax: timeMax,
        singleEvents: true,
        orderBy: "startTime"
    };

    stream<calendar:Event, error?> eventStream = check calendarClient->getEvents(calendarId, filter = filter);

    string[] lines = check from calendar:Event ev in eventStream
        select string `- ${ev.summary ?: "(no title)"} | ${ev.'start?.dateTime ?: ev.'start?.date ?: "unknown time"} → ${ev.end?.dateTime ?: ev.end?.date ?: "unknown time"}`;
    if lines.length() == 0 {
        return string `No events found for ${targetDate}.`;
    }
    return string `Events for ${targetDate}:\n` + string:'join("\n", ...lines);
}

@ai:AgentTool
isolated function createTask(string title, string? notes = (), string? dueDate = ()) returns string|error {
    string? due = ();
    if dueDate is string {
        // Accept only a plain date (YYYY-MM-DD); reject full timestamps to avoid invalid values
        if dueDate.matches(re `\d{4}-\d{2}-\d{2}`) {
            due = string `${dueDate}T00:00:00.000Z`;
        } else {
            return error(string `Invalid dueDate format "${dueDate}". Expected YYYY-MM-DD.`);
        }
    }
    gtasks:Task newTask = {
        title: title,
        notes: notes,
        due: due
    };
    gtasks:Task created = check tasksClient->insertTasks(tasksListId, newTask);
    return string `Task created: "${created.title ?: title}"`;
}

@ai:AgentTool
isolated function getTasks() returns string|error {
    string[] lines = [];
    string? pageToken = ();
    // Paginate through all task pages using a while loop
    while true {
        gtasks:Tasks result = check tasksClient->listTasks(tasksListId,
            showCompleted = false,
            pageToken = pageToken
        );
        gtasks:Task[] items = result.items ?: [];
        foreach gtasks:Task task in items {
            string taskTitle = task.title ?: "(untitled)";
            string due = "";
            string? dueStr = task.due;
            if dueStr is string && dueStr.length() >= 10 {
                due = string ` (due: ${dueStr.substring(0, 10)})`;
            }
            lines.push(string `- ${taskTitle}${due}`);
        }
        string? next = result.nextPageToken;
        if next is () {
            break;
        }
        pageToken = next;
    }
    if lines.length() == 0 {
        return "No pending tasks found.";
    }
    return "Your pending tasks:\n" + string:'join("\n", ...lines);
}
