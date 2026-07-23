type SheetRow (int|string|decimal)[];

type JiraIssueFields record {|
    string summary?;
    record {| string name; |} status?;
    record {| string displayName; |} assignee?;
    string created?;
    string duedate?;
|};

type IssueData record {
    string key;
    IssueFields fields;
};

type IssueFields record {
    string summary;
    StatusData status;
    AssigneeData? assignee;
    string created;
    string dueDate;
};

type StatusData record {
    string name;
};

type AssigneeData record {
    string displayName;
};
