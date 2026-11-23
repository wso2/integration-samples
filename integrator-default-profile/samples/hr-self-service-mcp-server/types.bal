public enum LeaveType {
    ANNUAL = "annual",
    SICK = "sick",
    PERSONAL = "personal"
}

public enum LeaveStatus {
    PENDING = "pending",
    APPROVED = "approved",
    REJECTED = "rejected",
    CANCELLED = "cancelled"
}

public type LeaveBalanceEntry record {|
    int entitled;
    int used;
|};

public type LeaveBalances record {|
    LeaveBalanceEntry annual;
    LeaveBalanceEntry sick;
    LeaveBalanceEntry personal;
|};

public type Employee record {|
    string id;
    string name;
    string email;
    string title;
    string department;
    string? managerId;
    LeaveBalances leaveBalances;
|};

public type LeaveRequest record {|
    string id;
    string employeeId;
    LeaveType leaveType;
    string startDate;
    string endDate;
    int days;
    string reason?;
    LeaveStatus status;
    string submittedAt;
    string decidedBy?;
    string decidedAt?;
    string decisionComment?;
|};

// The in-memory data set, loaded from data.json at startup.
public type DataSet record {|
    Employee[] employees;
    LeaveRequest[] leaveRequests;
|};

public type Profile record {|
    string id;
    string name;
    string email;
    string title;
    string department;
    string? managerId;
    string? managerName;
    string[] directReports;
|};

public type LeaveBalanceSummary record {|
    LeaveType leaveType;
    int entitled;
    int used;
    int pending;
    int available;
|};

public type LeaveBalanceReport record {|
    string employeeId;
    string employeeName;
    LeaveBalanceSummary[] balances;
|};

public type LeaveRequestView record {|
    *LeaveRequest;
    string employeeName;
|};
