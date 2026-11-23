import ballerina/time;

public type AccountStatus "Active"|"Locked"|"Disabled";

public type App "Slack"|"Zoom"|"Jira"|"Confluence"|"Salesforce"|"AWS console"|"Payroll";

public type RequestStatus "PENDING"|"APPROVED"|"REJECTED";

public type TicketCategory "Network"|"Email"|"Hardware"|"Software"|"Account"|"Access"|"Other";

public type TicketPriority "Low"|"Medium"|"High"|"Critical";

public type TicketStatus "Open"|"In Progress"|"Resolved"|"Closed";

public type Employee record {|
    string email;
    string name;
    string employeeId;
    string department;
    string managerEmail;
    AccountStatus status;
    App[] apps;
|};

// What the model may see about an employee: no employee ID and no manager email.
public type EmployeeProfile record {|
    string email;
    string name;
    string department;
    AccountStatus status;
    App[] apps;
|};

public type AccessRequest record {|
    string requestId;
    string employeeEmail;
    App app;
    string managerEmail;
    RequestStatus status;
    string requestedAt;
    string decidedAt?;
    string comment?;
|};

// What the model may see about an access request: no manager email.
public type AccessRequestView record {|
    string requestId;
    string employeeEmail;
    App app;
    RequestStatus status;
    string requestedAt;
    string decidedAt?;
    string comment?;
|};

public type Ticket record {|
    string ticketId;
    string employeeEmail;
    TicketCategory category;
    TicketPriority priority;
    string summary;
    TicketStatus status;
    string createdAt;
    string updatedAt;
|};

public type AccessOutcome record {|
    "GRANTED"|"ALREADY_HAS_ACCESS"|"PENDING_MANAGER_APPROVAL" outcome;
    string message;
    string requestId?;
|};

public type ApprovalDecision record {|
    "approve"|"reject" decision;
    # Email address of the employee's manager; must match the manager on record
    string managerEmail;
    string comment?;
|};

type KbArticle record {|
    string id;
    string title;
    string body;
|};

type IdCheckFailures record {|
    time:Utc[] failedAt;
|};

type IdCheckResult "MATCH"|"MISMATCH"|"LOCKED_OUT";

type NotFoundError distinct error;

type ForbiddenError distinct error;

type ConflictError distinct error;
