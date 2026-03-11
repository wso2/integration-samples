function mapIssueToRow(IssueData issue) returns SheetRow {
    string key = issue.key;
    string summary = issue.fields.summary;
    string status = issue.fields.status.name;
    string assignee = issue.fields.assignee?.displayName ?: "Unassigned";
    string created = issue.fields.created;
    string dueDate = issue.fields.dueDate;

    return [key, summary, status, assignee, created, dueDate];
}
