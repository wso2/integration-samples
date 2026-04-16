public type Sprint record {| 
	int id;
	string name;
	string? startDate;
	string? completeDate;
	string? endDate;
|};

public type IssueDetails record {| 
	string key;
	string summary;
	string status;
	string statusCategory;
	string? assignee;
	string? created;
|};

public type AssigneeStats record {|
	string assigneeName;
	int completedCount;
	int carriedOverCount;
	int totalCount;
|};

public type SprintSummary record {| 
	string sprintName;
	int sprintId;
	string completedDate;
	int totalIssues;
	int completedIssues;
	int carriedOverIssues;
	IssueDetails[] completedIssuesList;
	IssueDetails[] carriedOverIssuesList;
	AssigneeStats[] assigneeBreakdown;
	IssueDetails[] midSprintAdditions;
	boolean includeCompletedIssues;
	boolean includeCarriedOverIssues;
	boolean includeAssigneeBreakdown;
	boolean includeMidSprintAdditions;
|};
