type SheetRow (int|string|decimal)[];

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
