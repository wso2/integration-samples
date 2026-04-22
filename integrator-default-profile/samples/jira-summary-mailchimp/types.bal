type IssueAssignee record {|
    string displayName;
    string avatarUrl;
    string emailAddress;
|};

type IssuePriority record {|
    string name;
    string iconUrl;
|};

type IssueStatus record {|
    string name;
    string colorName;
|};

type IssueProject record {|
    string name;
    string key;
    string avatarUrl;
|};

type Issue record {|
    string key;
    string summary;
    IssueAssignee? assignee;
    IssuePriority? priority;
    IssueStatus status;
    IssueProject? project;
    string issueUrl;
    string? dueDate;
    string? updated;
|};
