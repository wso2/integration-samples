import ballerina/ai;
import ballerina/time;
import ballerina/uuid;
import wso2/travel_advisor;

const CTX_EMPLOYEE_ID = "employeeId";
const CTX_SESSION_KEY = "sessionKey";
const CTX_APPROVER_ID = "approverId";
const CTX_TRAVELER_GRADE = "travelerGrade";

// ---- Employee directory: a stand-in for the HR system ----

final readonly & map<Employee> employeeDirectory = {
    "E1001": {
        employeeId: "E1001",
        fullName: "Alex Morgan",
        email: "alex.morgan@example.com",
        grade: "staff",
        managerId: "M2001",
        costCenter: "CC-ENG-410"
    },
    "M2001": {
        employeeId: "M2001",
        fullName: "Priya Raman",
        email: "priya.raman@example.com",
        grade: "director",
        managerId: "V3001",
        costCenter: "CC-ENG-400"
    },
    "V3001": {
        employeeId: "V3001",
        fullName: "Sam Okafor",
        email: "sam.okafor@example.com",
        grade: "vp",
        managerId: (),
        costCenter: "CC-ENG-100"
    }
};

isolated function findEmployee(string employeeId) returns Employee? => employeeDirectory[employeeId];

isolated function getEmployee(string employeeId) returns Employee|error {
    Employee? employee = employeeDirectory[employeeId];
    if employee is () {
        return error(string `Unknown employee '${employeeId}'`);
    }
    return employee;
}

isolated function currentTraveler(ai:Context context) returns Employee|error {
    string employeeId = check context.getWithType(CTX_EMPLOYEE_ID);
    return getEmployee(employeeId);
}

# Who must approve a trip, in order: the traveler's manager, then that manager's manager when the policy asks for
# a second approval and there is one. Empty when the traveler has no manager.
# + traveler - The employee who is traveling
# + needsSecondApproval - Whether the policy asks for a second approval
# + return - The approvers' employee IDs, in the order they decide
isolated function approvalChainFor(Employee traveler, boolean needsSecondApproval) returns string[] {
    string? managerId = traveler.managerId;
    if managerId is () {
        return [];
    }
    Employee? manager = findEmployee(managerId);
    string? secondApproverId = manager is Employee ? manager.managerId : ();
    if needsSecondApproval && secondApproverId is string {
        return [managerId, secondApproverId];
    }
    return [managerId];
}

// ---- Requests, approvals and sessions ----
// In-memory state. Swap for a database before running more than one replica: requests, pending approvals
// and the agents' memory must survive restarts and be shared across instances.

// Requests and approvals share one lock, so a submission can be checked and reserved in one step.
# The in-memory store of trip requests and the approvals waiting for a decision.
type TripStore record {|
    # Trip requests by request ID
    map<TripRequest> requests = {};
    # Pending approvals by approval ID
    map<PendingApproval> approvals = {};
|};

isolated TripStore store = {};
isolated map<boolean> activeSessions = {};

isolated function nowIso() returns string => time:utcToString(time:utcNow());

isolated function newId(string prefix) returns string =>
    prefix + uuid:createType4AsString().substring(0, 8).toUpperAscii();

isolated function saveRequest(TripRequest request) {
    lock {
        store.requests[request.requestId] = request.clone();
    }
}

isolated function getRequest(string requestId) returns TripRequest? {
    lock {
        return store.requests[requestId].clone();
    }
}

isolated function addAuditEvent(string requestId, string actor, string action, string detail) {
    lock {
        TripRequest? request = store.requests[requestId];
        if request is TripRequest {
            request.auditTrail.push({at: nowIso(), actor, action, detail});
        }
    }
}

# Whether an employee may read a request: the traveler, or one of its approvers.
# + request - The trip request
# + employeeId - The employee asking to read it
# + return - True for the traveler and the request's approvers
isolated function canView(TripRequest request, string employeeId) returns boolean =>
    request.employeeId == employeeId || request.approvalChain.indexOf(employeeId) is int;

# Checks a batch of new submissions and stores them as pending approvals, in one step, so two conversations
# cannot both submit the same request. Nothing is stored unless every submission passes.
# + submissions - The new pending approvals, one per submitted request
# + traveler - The employee submitting them
# + return - The reason each failed submission cannot be submitted, by approval ID; empty when all were stored
isolated function reserveSubmissions(PendingApproval[] submissions, Employee traveler) returns map<string> {
    readonly & PendingApproval[] incoming = submissions.cloneReadOnly();
    string travelerId = traveler.employeeId;
    lock {
        map<string> problems = {};
        string[] batch = [];
        foreach PendingApproval submission in incoming {
            string requestId = submission.requestId;
            TripRequest? request = store.requests[requestId];
            string? problem = ();
            if request is () || request.employeeId != travelerId {
                problem = string `Request '${requestId}' is not one of this traveler's requests, ` +
                    "so it cannot be submitted.";
            } else if request.status != "PREPARED" {
                problem = string `Request '${requestId}' is already ${request.status}, ` +
                    "so it cannot be submitted again.";
            } else if !request.policy.submittable {
                problem = string `Request '${requestId}' cannot be submitted: ` +
                    string:'join("; ", ...request.policy.blockers);
            } else if request.approvalChain.length() == 0 {
                problem = string `Request '${requestId}' has no approver, so it cannot be submitted.`;
            } else if batch.indexOf(requestId) is int {
                problem = string `Request '${requestId}' was submitted twice in one step.`;
            } else if isAwaitingDecision(store.approvals, requestId) {
                problem = string `Request '${requestId}' is already waiting for a decision.`;
            }
            batch.push(requestId);
            if problem is string {
                problems[submission.approvalId] = problem;
            }
        }
        if problems.length() > 0 {
            return problems.clone();
        }
        foreach PendingApproval submission in incoming {
            // A fresh, mutable record: cloning the read-only submission would keep it read-only.
            PendingApproval stored = {...submission};
            store.approvals[submission.approvalId] = stored;
            TripRequest? request = store.requests[submission.requestId];
            if request is TripRequest {
                request.auditTrail.push({at: nowIso(), actor: travelerId, action: "SUBMITTED_FOR_APPROVAL",
                    detail: "Approvers: " + string:'join(", ", ...submission.approvalChain)});
            }
        }
        return {};
    }
}

isolated function isAwaitingDecision(map<PendingApproval> approvals, string requestId) returns boolean {
    foreach PendingApproval approval in approvals {
        if approval.requestId == requestId {
            return true;
        }
    }
    return false;
}

isolated function isPendingApproval(string approvalId) returns boolean {
    lock {
        return store.approvals.hasKey(approvalId);
    }
}

isolated function findPendingApproval(string approvalId) returns PendingApproval? {
    lock {
        return store.approvals[approvalId].clone();
    }
}

# Pending approvals waiting for an approver's decision.
# + approverId - The approver's employee ID
# + return - The approvals where this approver decides next and no decision is in progress
isolated function pendingApprovalsFor(string approverId) returns PendingApproval[] {
    lock {
        PendingApproval[] matches = from PendingApproval approval in store.approvals
            where approval.approvalChain[approval.stage] == approverId && !approval.deciding
            select approval;
        return matches.clone();
    }
}

isolated function pendingApprovalsInSession(string sessionKey) returns PendingApproval[] {
    lock {
        PendingApproval[] matches = from PendingApproval approval in store.approvals
            where approval.sessionKey == sessionKey
            select approval;
        return matches.clone();
    }
}

# Claims a pending approval for a decision. The approval stays stored, marked as being decided, until
# `completeApproval` or `advanceApproval`, so its request stays reserved meanwhile.
# + approvalId - The approval to claim
# + return - The approval, or nil when it is gone or another decision is in progress
isolated function claimApproval(string approvalId) returns PendingApproval? {
    lock {
        PendingApproval? approval = store.approvals[approvalId];
        if approval is () || approval.deciding {
            return ();
        }
        approval.deciding = true;
        return approval.clone();
    }
}

# Hands a claimed approval to the next approver in its chain.
# + approvalId - The claimed approval
# + return - The approval, now waiting for the next approver, or nil when it is gone
isolated function advanceApproval(string approvalId) returns PendingApproval? {
    lock {
        PendingApproval? approval = store.approvals[approvalId];
        if approval is () {
            return ();
        }
        approval.stage += 1;
        approval.deciding = false;
        return approval.clone();
    }
}

isolated function completeApproval(string approvalId) {
    lock {
        if store.approvals.hasKey(approvalId) {
            _ = store.approvals.remove(approvalId);
        }
    }
}

isolated function markRejected(string requestId, string approverId, string reason) {
    lock {
        TripRequest? request = store.requests[requestId];
        if request is TripRequest && request.status == "PREPARED" {
            request.status = "REJECTED";
            request.auditTrail.push({at: nowIso(), actor: approverId, action: "REJECTED", detail: reason});
        }
    }
}

# Issues the travel authorization once the last approver has approved. The FCDO advice is checked again first:
# if it now advises against all travel, or newly advises against non-essential travel (which the approvers did
# not see), the request is stopped instead.
# + requestId - The approved trip request
# + employeeId - The traveler's employee ID
# + approverId - The last approver
# + return - The request in its final state, or an error when it cannot be authorized by this approver
isolated function authorizeRequest(string requestId, string employeeId, string approverId)
        returns TripRequest|error {
    TripRequest? current = getRequest(requestId);
    if current is () || current.employeeId != employeeId {
        return error(string `Unknown request '${requestId}'`);
    }
    if current.status != "PREPARED" {
        // Already decided: report the current state instead of deciding twice.
        return current;
    }
    if current.approvalChain.length() == 0 || current.approvalChain[current.approvalChain.length() - 1] != approverId {
        return error("Only the last approver in the chain can authorize this trip");
    }
    travel_advisor:TravelAdvisory|error advisory = travel_advisor:travelAdvisory(current.countryName);
    string? stopReason = ();
    string[] conditions = current.policy.warnings.clone();
    if advisory is travel_advisor:TravelAdvisory {
        if advisory.adviceLevel == "AVOID_ALL_TRAVEL" {
            stopReason = "The FCDO now advises against all travel to the destination";
        } else if advisory.adviceLevel == "ESSENTIAL_TRAVEL_ONLY"
                && current.policy.adviceLevel != "ESSENTIAL_TRAVEL_ONLY" {
            stopReason = "The FCDO now advises against all but essential travel to the destination, which the " +
                "approvers did not see";
        }
        conditions.push(string `Check the FCDO advice again before departure: ${advisory.sourceUrl}`);
    } else {
        conditions.push("The FCDO advice could not be checked when this authorization was issued; check it before " +
            "departure");
    }
    readonly & string[] finalConditions = conditions.cloneReadOnly();
    lock {
        TripRequest? request = store.requests[requestId];
        if request is () {
            return error(string `Unknown request '${requestId}'`);
        }
        if request.status != "PREPARED" {
            return request.clone();
        }
        string at = nowIso();
        if stopReason is string {
            request.status = "STOPPED";
            request.auditTrail.push({at, actor: "system", action: "STOPPED", detail: stopReason});
        } else {
            request.status = "AUTHORIZED";
            request.authorization = {
                authorizationId: newId("TA-"),
                issuedAt: at,
                approvedBy: request.approvalChain.clone(),
                conditions: finalConditions
            };
            request.auditTrail.push({at, actor: "system", action: "AUTHORIZED",
                detail: "Approved by " + string:'join(", ", ...request.approvalChain)});
        }
        return request.clone();
    }
}

// One agent run per conversation at a time: ai:Agent.run is not safe to call concurrently for a session.
isolated function tryAcquireSession(string sessionKey) returns boolean {
    lock {
        if activeSessions.hasKey(sessionKey) {
            return false;
        }
        activeSessions[sessionKey] = true;
        return true;
    }
}

isolated function releaseSession(string sessionKey) {
    lock {
        if activeSessions.hasKey(sessionKey) {
            _ = activeSessions.remove(sessionKey);
        }
    }
}
