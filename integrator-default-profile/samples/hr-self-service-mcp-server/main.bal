import ballerina/io;
import ballerina/log;
import ballerina/mcp.v2 as mcpv2;

const string dataFilePath = "data.json";
const int serverPort = 9091;

final string mcpResourceUrl = buildResourceUrl(serverPublicUrl);

listener mcpv2:StreamableHttpListener hrListener = new (serverPort);

@mcpv2:StreamableHttpServiceConfig {
    info: {name: "hr-leave-management", version: "1.0.0"},
    httpConfig: {
        auth: {
            'resource: mcpResourceUrl,
            resourceName: "HR Self-Service Leave Management",
            authorizationServers: [
                {
                    issuer: oauthIssuer,
                    audience: oauthAudience,
                    validator: {
                        jwtValidatorConfig: {
                            scopeKey: oauthScopeClaim,
                            signatureConfig: {jwksConfig: {url: oauthJwksUrl}}
                        }
                    }
                }
            ],
            scopesSupported: [hrReadScope, hrWriteScope, hrApproveScope, hrReadAllScope],
            scopeHierarchy: {[hrReadAllScope]: [hrReadScope]}
        }
    }
}
service mcpv2:StreamableHttpService /mcp on hrListener {

    # Get the profile of the signed-in employee: name, title, department, manager and direct reports.
    # + auth - The authenticated caller
    # + return - The caller's profile
    @mcpv2:Tool {scopes: [hrReadScope]}
    remote isolated function getMyProfile(mcpv2:AuthContext auth) returns Profile|error {
        Employee caller = check resolveCaller(auth);
        DataSet snapshot = snapshotData();
        return buildProfile(caller, snapshot);
    }

    # Get leave balances (annual, sick, personal) with entitled, used, pending and available days.
    # Defaults to the signed-in employee. Another employee's balance requires the hr:read:all scope.
    # + auth - The authenticated caller
    # + employeeId - Optional employee id or email of another employee
    # + return - The leave balances
    @mcpv2:Tool {scopes: [hrReadScope]}
    remote isolated function getLeaveBalance(mcpv2:AuthContext auth, string? employeeId = ())
            returns LeaveBalanceReport|error {
        Employee target = check resolveReadTarget(auth, employeeId);
        DataSet snapshot = snapshotData();
        return buildBalanceReport(target, snapshot);
    }

    # List leave requests, optionally filtered by status (pending, approved, rejected, cancelled).
    # Defaults to the signed-in employee. Another employee's requests require the hr:read:all scope.
    # + auth - The authenticated caller
    # + employeeId - Optional employee id or email of another employee
    # + status - Optional status filter
    # + return - The matching leave requests
    @mcpv2:Tool {scopes: [hrReadScope]}
    remote isolated function listLeaveRequests(mcpv2:AuthContext auth, string? employeeId = (),
            LeaveStatus? status = ()) returns LeaveRequestView[]|error {
        Employee target = check resolveReadTarget(auth, employeeId);
        return listRequestsFor(target, status);
    }

    # Apply for leave for the signed-in employee. Dates are inclusive and must be working days (Monday to
    # Friday) that are today or later. Weekends in between are not counted. The request needs enough
    # available balance and must not overlap a pending or approved request.
    # + auth - The authenticated caller
    # + leaveType - Type of leave: annual, sick or personal
    # + startDate - First day of leave, YYYY-MM-DD
    # + endDate - Last day of leave, YYYY-MM-DD
    # + reason - Optional reason
    # + return - The created leave request, in pending status
    @mcpv2:Tool {scopes: [hrWriteScope]}
    remote isolated function applyForLeave(mcpv2:AuthContext auth, LeaveType leaveType, string startDate,
            string endDate, string? reason = ()) returns LeaveRequest|error {
        Employee caller = check resolveCaller(auth);
        int startDay = check parseDate(startDate);
        int endDay = check parseDate(endDate);
        if startDay < currentDay() {
            return error("Leave cannot start in the past.");
        }
        if endDay < startDay {
            return error("The end date must not be before the start date.");
        }
        if !isWorkingDay(startDay) || !isWorkingDay(endDay) {
            return error("The start and end dates must be working days (Monday to Friday).");
        }
        int days = countWorkingDays(startDay, endDay);
        return submitLeave(caller.id, leaveType, startDate, endDate, days, reason);
    }

    # Cancel one of the signed-in employee's own leave requests. Only pending requests can be cancelled.
    # + auth - The authenticated caller
    # + requestId - Id of the leave request, for example L-1002
    # + return - The cancelled leave request
    @mcpv2:Tool {scopes: [hrWriteScope]}
    remote isolated function cancelLeaveRequest(mcpv2:AuthContext auth, string requestId)
            returns LeaveRequest|error {
        Employee caller = check resolveCaller(auth);
        return cancelRequest(caller.id, requestId);
    }

    # List pending leave requests from the signed-in manager's direct reports.
    # + auth - The authenticated caller
    # + return - Pending leave requests awaiting the caller's decision
    @mcpv2:Tool {scopes: [hrApproveScope]}
    remote isolated function listPendingApprovals(mcpv2:AuthContext auth) returns LeaveRequestView[]|error {
        Employee caller = check resolveCaller(auth);
        return listPendingFor(caller);
    }

    # Approve a pending leave request of a direct report.
    # + auth - The authenticated caller
    # + requestId - Id of the leave request
    # + comment - Optional comment
    # + return - The approved leave request
    @mcpv2:Tool {scopes: [hrApproveScope]}
    remote isolated function approveLeaveRequest(mcpv2:AuthContext auth, string requestId, string? comment = ())
            returns LeaveRequest|error {
        Employee caller = check resolveCaller(auth);
        return decideRequest(caller.id, requestId, true, comment);
    }

    # Reject a pending leave request of a direct report. A comment is required.
    # + auth - The authenticated caller
    # + requestId - Id of the leave request
    # + comment - Reason for rejection (required)
    # + return - The rejected leave request
    @mcpv2:Tool {scopes: [hrApproveScope]}
    remote isolated function rejectLeaveRequest(mcpv2:AuthContext auth, string requestId, string comment)
            returns LeaveRequest|error {
        Employee caller = check resolveCaller(auth);
        if comment.trim() == "" {
            return error("A comment is required when rejecting a leave request.");
        }
        return decideRequest(caller.id, requestId, false, comment);
    }
}

public function main() returns error? {
    json raw = check io:fileReadJson(dataFilePath);
    DataSet loaded = check raw.cloneWithType();
    lock {
        dataStore = loaded.clone();
    }
    log:printInfo("Sample HR data loaded", employees = loaded.employees.length(),
            leaveRequests = loaded.leaveRequests.length());
}
