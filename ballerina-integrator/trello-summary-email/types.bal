import ballerina/time;

public enum SummaryGrouping {
    LIST,
    MEMBER,
    LABEL
}

public type CardSummary record {|
    string id;
    string name;
    string listName;
    string boardName;
    string url;
    string[] labels;
    string[] members;
    time:Civil? dueDate;
    boolean isOverdue;
    string description;
    int cardAgeDays;
    boolean isStale;
    int attachmentCount;
    int checklistItemsTotal;
    int checklistItemsCompleted;
    decimal checklistCompletionPercentage;
|};

public type GroupedSummary record {|
    string groupName;
    CardSummary[] cards;
|};
