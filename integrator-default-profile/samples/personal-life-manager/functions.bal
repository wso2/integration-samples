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
    time:Civil now = time:utcToCivil(time:utcNow());
    string month = now.month < 10 ? string `0${now.month}` : now.month.toString();
    string day = now.day < 10 ? string `0${now.day}` : now.day.toString();
    string targetDate = date.length() > 0 ? date : string `${now.year}-${month}-${day}`;

    string timeMin = string `${targetDate}T00:00:00Z`;
    string timeMax = string `${targetDate}T23:59:59Z`;

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
    gtasks:Task newTask = {
        title: title,
        notes: notes,
        due: dueDate is string ? string `${dueDate}T00:00:00.000Z` : ()
    };
    gtasks:Task created = check tasksClient->insertTasks(tasksListId, newTask);
    return string `Task created: "${created.title ?: title}"`;
}

@ai:AgentTool
isolated function getTasks() returns string|error {
    gtasks:Tasks result = check tasksClient->listTasks(tasksListId, showCompleted = false);
    gtasks:Task[] items = result.items ?: [];
    if items.length() == 0 {
        return "No pending tasks found.";
    }
    string[] lines = [];
    foreach gtasks:Task task in items {
        string taskTitle = task.title ?: "(untitled)";
        string due = "";
        string? dueStr = task.due;
        if dueStr is string && dueStr.length() >= 10 {
            due = string ` (due: ${dueStr.substring(0, 10)})`;
        }
        lines.push(string `- ${taskTitle}${due}`);
    }
    return "Your pending tasks:\n" + string:'join("\n", ...lines);
}
