import ballerina/mcp.v2 as mcpv2;
import ballerina/time;

const string hrReadScope = "hr:read";
const string hrWriteScope = "hr:write";
const string hrApproveScope = "hr:approve";
const string hrReadAllScope = "hr:read:all";

const int secondsPerDay = 86400;

isolated DataSet dataStore = {employees: [], leaveRequests: []};

isolated function snapshotData() returns DataSet {
    lock {
        return dataStore.clone();
    }
}

isolated function buildResourceUrl(string baseUrl) returns string {
    string trimmed = baseUrl.trim();
    if trimmed.endsWith("/") {
        trimmed = trimmed.substring(0, trimmed.length() - 1);
    }
    return trimmed + "/mcp";
}

// Finds an employee by email or id (case-insensitive).
isolated function findEmployee(string key) returns Employee? {
    string lowered = key.trim().toLowerAscii();
    DataSet snapshot = snapshotData();
    foreach Employee employee in snapshot.employees {
        if employee.email.toLowerAscii() == lowered || employee.id.toLowerAscii() == lowered {
            return employee;
        }
    }
    return ();
}

// Identifies the signed-in user from the configured token claim.
isolated function resolveCaller(mcpv2:AuthContext auth) returns Employee|error {
    json claimValue = auth.claims[userClaim];
    if claimValue !is string || claimValue.trim() == "" {
        return error(string `The access token has no '${userClaim}' claim to identify the user.`);
    }
    Employee? employee = findEmployee(claimValue);
    if employee is () {
        return error(string `No employee record matches the signed-in user '${claimValue}'.`);
    }
    return employee;
}

isolated function hasScope(mcpv2:AuthContext auth, string scope) returns boolean {
    return auth.scopes.indexOf(scope) is int;
}

// Resolves whose data to read: the caller's own by default; someone else's requires hr:read:all.
isolated function resolveReadTarget(mcpv2:AuthContext auth, string? employeeId) returns Employee|error {
    Employee caller = check resolveCaller(auth);
    if employeeId is () {
        return caller;
    }
    string requested = employeeId.trim().toLowerAscii();
    if requested == "" || requested == caller.id.toLowerAscii() || requested == caller.email.toLowerAscii() {
        return caller;
    }
    if !hasScope(auth, hrReadAllScope) {
        return error mcpv2:InsufficientScopeError(
            "Reading another employee's data requires the hr:read:all scope.", scopes = [hrReadAllScope]);
    }
    Employee? target = findEmployee(requested);
    if target is () {
        return error(string `No employee found for '${employeeId}'.`);
    }
    return target;
}

isolated function entryFor(LeaveBalances balances, LeaveType leaveType) returns LeaveBalanceEntry {
    if leaveType == ANNUAL {
        return balances.annual;
    }
    if leaveType == SICK {
        return balances.sick;
    }
    return balances.personal;
}

isolated function buildProfile(Employee employee, DataSet snapshot) returns Profile {
    string? managerName = ();
    string[] directReports = [];
    foreach Employee other in snapshot.employees {
        if other.id == employee.managerId {
            managerName = other.name;
        }
        if other.managerId == employee.id {
            directReports.push(other.name);
        }
    }
    return {
        id: employee.id,
        name: employee.name,
        email: employee.email,
        title: employee.title,
        department: employee.department,
        managerId: employee.managerId,
        managerName: managerName,
        directReports: directReports
    };
}

isolated function buildBalanceReport(Employee employee, DataSet snapshot) returns LeaveBalanceReport {
    LeaveType[] leaveTypes = [ANNUAL, SICK, PERSONAL];
    LeaveBalanceSummary[] summaries = [];
    foreach LeaveType leaveType in leaveTypes {
        LeaveBalanceEntry entry = entryFor(employee.leaveBalances, leaveType);
        int pending = 0;
        foreach LeaveRequest request in snapshot.leaveRequests {
            if request.employeeId == employee.id && request.leaveType == leaveType && request.status == PENDING {
                pending += request.days;
            }
        }
        summaries.push({
            leaveType: leaveType,
            entitled: entry.entitled,
            used: entry.used,
            pending: pending,
            available: entry.entitled - entry.used - pending
        });
    }
    return {employeeId: employee.id, employeeName: employee.name, balances: summaries};
}

isolated function matchesStatus(LeaveStatus? filter, LeaveStatus actual) returns boolean {
    return filter is () || filter == actual;
}

isolated function listRequestsFor(Employee employee, LeaveStatus? statusFilter) returns LeaveRequestView[] {
    DataSet snapshot = snapshotData();
    LeaveRequestView[] views = [];
    foreach LeaveRequest request in snapshot.leaveRequests {
        if request.employeeId == employee.id && matchesStatus(statusFilter, request.status) {
            views.push({...request, employeeName: employee.name});
        }
    }
    return views;
}

isolated function listPendingFor(Employee manager) returns LeaveRequestView[] {
    DataSet snapshot = snapshotData();
    LeaveRequestView[] views = [];
    foreach LeaveRequest request in snapshot.leaveRequests {
        if request.status != PENDING {
            continue;
        }
        foreach Employee employee in snapshot.employees {
            if employee.id == request.employeeId && employee.managerId == manager.id {
                views.push({...request, employeeName: employee.name});
                break;
            }
        }
    }
    return views;
}

// Date helpers. Dates are handled as day numbers since 1970-01-01 (UTC).

isolated function currentDay() returns int {
    time:Utc now = time:utcNow();
    return now[0] / secondsPerDay;
}

isolated function parseDate(string text) returns int|error {
    string:RegExp pattern = re `\d{4}-\d{2}-\d{2}`;
    if !pattern.isFullMatch(text) {
        return error(string `Invalid date '${text}'. Use the format YYYY-MM-DD.`);
    }
    int year = check int:fromString(text.substring(0, 4));
    int month = check int:fromString(text.substring(5, 7));
    int day = check int:fromString(text.substring(8, 10));
    time:Error? validation = time:dateValidate({year: year, month: month, day: day});
    if validation is time:Error {
        return error(string `Invalid date '${text}'.`);
    }
    time:Civil civil = {year: year, month: month, day: day, hour: 0, minute: 0, second: 0, utcOffset: {hours: 0, minutes: 0}};
    time:Utc utc = check time:utcFromCivil(civil);
    return utc[0] / secondsPerDay;
}

// The epoch day 0 (1970-01-01) was a Thursday.
isolated function isWorkingDay(int dayNumber) returns boolean {
    int weekday = (dayNumber + 4) % 7;
    return weekday != 0 && weekday != 6;
}

isolated function countWorkingDays(int startDay, int endDay) returns int {
    int count = 0;
    int current = startDay;
    while current <= endDay {
        if isWorkingDay(current) {
            count += 1;
        }
        current += 1;
    }
    return count;
}

isolated function submitLeave(string employeeId, LeaveType leaveType, string startDate, string endDate, int days,
        string? reason) returns LeaveRequest|error {
    string submittedAt = time:utcToString(time:utcNow());
    lock {
        int entitled = 0;
        int used = 0;
        boolean found = false;
        foreach Employee employee in dataStore.employees {
            if employee.id == employeeId {
                found = true;
                LeaveBalanceEntry entry = entryFor(employee.leaveBalances.clone(), leaveType);
                entitled = entry.entitled;
                used = entry.used;
            }
        }
        if !found {
            return error(string `Employee '${employeeId}' not found.`);
        }
        int pending = 0;
        foreach LeaveRequest existing in dataStore.leaveRequests {
            if existing.employeeId != employeeId {
                continue;
            }
            boolean active = existing.status == PENDING || existing.status == APPROVED;
            if active && existing.startDate <= endDate && existing.endDate >= startDate {
                return error(string `The dates overlap with your ${existing.status} request ${existing.id} (${existing.startDate} to ${existing.endDate}).`);
            }
            if existing.status == PENDING && existing.leaveType == leaveType {
                pending += existing.days;
            }
        }
        int available = entitled - used - pending;
        if days > available {
            return error(string `Insufficient ${leaveType} leave balance: ${days} working day(s) requested, ${available} available.`);
        }
        // Continue from the highest existing request number, so edited sample data cannot produce duplicates
        int highestNumber = 1000;
        foreach LeaveRequest existing in dataStore.leaveRequests {
            if existing.id.startsWith("L-") {
                int|error number = int:fromString(existing.id.substring(2));
                if number is int && number > highestNumber {
                    highestNumber = number;
                }
            }
        }
        string newId = string `L-${highestNumber + 1}`;
        LeaveRequest created = {
            id: newId,
            employeeId: employeeId,
            leaveType: leaveType,
            startDate: startDate,
            endDate: endDate,
            days: days,
            status: PENDING,
            submittedAt: submittedAt
        };
        if reason is string && reason.trim() != "" {
            created.reason = reason.trim();
        }
        dataStore.leaveRequests.push(created);
        return created.clone();
    }
}

isolated function cancelRequest(string employeeId, string requestId) returns LeaveRequest|error {
    lock {
        foreach LeaveRequest existing in dataStore.leaveRequests {
            if existing.id == requestId && existing.employeeId == employeeId {
                if existing.status != PENDING {
                    return error(string `Only pending requests can be cancelled. Request ${requestId} is ${existing.status}.`);
                }
                existing.status = CANCELLED;
                return existing.clone();
            }
        }
    }
    return error(string `Leave request '${requestId}' was not found among your requests.`);
}

isolated function decideRequest(string managerId, string requestId, boolean approve, string? comment)
        returns LeaveRequest|error {
    string decidedAt = time:utcToString(time:utcNow());
    lock {
        foreach LeaveRequest existing in dataStore.leaveRequests {
            if existing.id != requestId {
                continue;
            }
            foreach Employee employee in dataStore.employees {
                if employee.id != existing.employeeId {
                    continue;
                }
                if employee.managerId != managerId {
                    return error(string `Request ${requestId} is not from one of your direct reports.`);
                }
                if existing.status != PENDING {
                    return error(string `Request ${requestId} is already ${existing.status}.`);
                }
                if approve {
                    if existing.leaveType == ANNUAL {
                        employee.leaveBalances.annual.used += existing.days;
                    } else if existing.leaveType == SICK {
                        employee.leaveBalances.sick.used += existing.days;
                    } else {
                        employee.leaveBalances.personal.used += existing.days;
                    }
                    existing.status = APPROVED;
                } else {
                    existing.status = REJECTED;
                }
                existing.decidedBy = managerId;
                existing.decidedAt = decidedAt;
                if comment is string && comment.trim() != "" {
                    existing.decisionComment = comment.trim();
                }
                return existing.clone();
            }
        }
    }
    return error(string `Leave request '${requestId}' was not found.`);
}
