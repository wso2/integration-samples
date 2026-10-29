function mapIssueToRow(IssueData issue) returns SheetRow =>
    let IssueFields fields = issue.fields in
    [
        issue.key,
        fields.summary,
        fields.status.name,
        fields.assignee?.displayName ?: "Unassigned",
        fields.created,
        fields.dueDate
    ];
