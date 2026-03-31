function mapToIssue(string key, record {|anydata...;|} fields) returns Issue|error {
    anydata summaryField = fields["summary"];
    anydata statusField = fields["status"];
    anydata priorityField = fields["priority"];
    anydata assigneeField = fields["assignee"];
    anydata projectField = fields["project"];
    anydata dueDateField = fields["duedate"];
    anydata updatedField = fields["updated"];

    string summary = summaryField is string ? summaryField : "No summary";

    IssueStatus status = {
        name: "Unknown",
        colorName: "gray"
    };

    if statusField is record {|anydata...;|} {
        anydata statusName = statusField["name"];
        anydata statusCategory = statusField["statusCategory"];

        if statusName is string {
            status.name = statusName;
        }

        if statusCategory is record {|anydata...;|} {
            anydata colorName = statusCategory["colorName"];
            if colorName is string {
                status.colorName = colorName;
            }
        }
    }

    IssueAssignee? assignee = ();
    if assigneeField is record {|anydata...;|} {
        anydata displayName = assigneeField["displayName"];
        anydata avatarUrls = assigneeField["avatarUrls"];
        anydata emailAddress = assigneeField["emailAddress"];

        string assigneeDisplayName = displayName is string ? displayName : "Unknown";
        string assigneeEmail = emailAddress is string ? emailAddress : "";
        string avatarUrl = "";

        if avatarUrls is record {|anydata...;|} {
            anydata avatar48 = avatarUrls["48x48"];
            if avatar48 is string {
                avatarUrl = avatar48;
            }
        }

        assignee = {
            displayName: assigneeDisplayName,
            avatarUrl: avatarUrl,
            emailAddress: assigneeEmail
        };
    }

    IssuePriority? priority = ();
    if priorityField is record {|anydata...;|} {
        anydata priorityName = priorityField["name"];
        anydata iconUrl = priorityField["iconUrl"];

        if priorityName is string && iconUrl is string {
            priority = {
                name: priorityName,
                iconUrl: iconUrl
            };
        }
    }

    IssueProject? project = ();
    if projectField is record {|anydata...;|} {
        anydata projectName = projectField["name"];
        anydata projectKey = projectField["key"];
        anydata avatarUrls = projectField["avatarUrls"];

        string projectNameStr = projectName is string ? projectName : "";
        string projectKeyStr = projectKey is string ? projectKey : "";
        string avatarUrl = "";

        if avatarUrls is record {|anydata...;|} {
            anydata avatar24 = avatarUrls["24x24"];
            if avatar24 is string {
                avatarUrl = avatar24;
            }
        }

        if projectNameStr != "" && projectKeyStr != "" {
            project = {
                name: projectNameStr,
                key: projectKeyStr,
                avatarUrl: avatarUrl
            };
        }
    }

    string? dueDate = dueDateField is string ? dueDateField : ();
    string? updated = updatedField is string ? updatedField : ();

    string issueUrl = string `${getJiraUrl()}/browse/${key}`;

    return {
        key: key,
        summary: summary,
        assignee: assignee,
        priority: priority,
        status: status,
        project: project,
        issueUrl: issueUrl,
        dueDate: dueDate,
        updated: updated
    };
}
