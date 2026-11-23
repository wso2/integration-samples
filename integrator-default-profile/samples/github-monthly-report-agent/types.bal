// A single flattened row representing either an open issue or an open pull request.
public type RepoItemRow record {|
    string 'type;
    int number;
    string title;
    string author;
    string assignee;
    string[] labels;
    int commentCount;
    string createdDate;
    int ageDays;
    string url;
|};
