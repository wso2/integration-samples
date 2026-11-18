import ballerina/ai;
import ballerina/http;
import ballerina/log;

// Caller identity comes from the `x-employee-id` header as a stand-in. In production, validate a JWT on the
// listener (`@http:ServiceConfig {auth: [...]}`) and read the subject claim instead.

// Agent runs with several tool calls can take minutes, so the timeout is longer than the default.
listener http:Listener travelListener = new (9090, timeout = 300);

service /travel on travelListener {

    # Chat with the trip planner. The conversation is scoped to the calling employee.
    # + employeeId - The calling employee
    # + request - Session ID and message
    # + return - The planner's reply, or the approvals the conversation is now waiting on
    resource function post chat(@http:Header {name: "x-employee-id"} string employeeId, ChatRequest request)
            returns ChatResponse|http:Forbidden|http:Conflict|http:InternalServerError {
        Employee? employee = findEmployee(employeeId);
        if employee is () {
            return <http:Forbidden>{body: <ErrorBody>{message: "Unknown employee"}};
        }
        string sessionKey = string `${employeeId}/${request.sessionId}`;
        // Hold the session from the approval check until any new approvals are stored, so an overlapping
        // request cannot slip in between.
        if !tryAcquireSession(sessionKey) {
            return <http:Conflict>{body: <ErrorBody>{message: "A request for this conversation is still running"}};
        }
        if pendingApprovalsInSession(sessionKey).length() > 0 {
            releaseSession(sessionKey);
            return <http:Conflict>{
                body: <ErrorBody>{message: "This conversation is waiting for manager approval. Start a new session."}
            };
        }
        ai:Context context = new;
        context.set(CTX_EMPLOYEE_ID, employeeId);
        context.set(CTX_SESSION_KEY, sessionKey);
        context.set(CTX_TRAVELER_GRADE, employee.grade);
        string|ai:Error result = tripPlanner.run(query = request.message, sessionId = sessionKey, context = context);
        ChatResponse|http:InternalServerError response = toChatResponse(sessionId = request.sessionId,
            sessionKey = sessionKey, traveler = employee, result = result);
        releaseSession(sessionKey);
        return response;
    }

    # Lists the bookings waiting for the calling manager's decision.
    # + approverId - The calling manager
    # + return - Pending approvals with the full proposal and policy result
    resource function get approvals(@http:Header {name: "x-employee-id"} string approverId) returns ApprovalView[] {
        return from PendingApproval approval in pendingApprovalsFor(approverId)
            select toApprovalView(approval);
    }

    # Approves or rejects a pending booking, then resumes the paused conversation.
    # + approverId - The calling manager
    # + approvalId - The approval to decide
    # + decision - APPROVE or REJECT, with an optional reason
    # + return - The planner's reply after the decision
    resource function post approvals/[string approvalId](@http:Header {name: "x-employee-id"} string approverId,
            ApprovalDecision decision)
            returns ChatResponse|http:NotFound|http:Forbidden|http:Conflict|http:InternalServerError {
        PendingApproval? found = findPendingApproval(approvalId);
        if found is () {
            return <http:NotFound>{body: <ErrorBody>{message: "No pending approval with that ID"}};
        }
        if found.approverId != approverId || found.employeeId == approverId {
            return <http:Forbidden>{body: <ErrorBody>{message: "Only the traveler's manager can decide this"}};
        }
        if !tryAcquireSession(found.sessionKey) {
            return <http:Conflict>{body: <ErrorBody>{message: "This conversation is busy; try again shortly"}};
        }
        PendingApproval? taken = takePendingApproval(approvalId);
        if taken is () {
            releaseSession(found.sessionKey);
            return <http:Conflict>{body: <ErrorBody>{message: "This approval was already decided"}};
        }
        PendingApproval pending = taken;
        Employee|error traveler = getEmployee(pending.employeeId);
        if traveler is error {
            releaseSession(pending.sessionKey);
            return <http:InternalServerError>{body: <ErrorBody>{message: traveler.message()}};
        }

        string reason = decision.reason ?: "Rejected by manager";
        readonly & ai:HumanDecision humanDecision = decision.outcome == "APPROVE"
            ? {outcome: ai:APPROVE}
            : {outcome: ai:REJECT, reason};
        if decision.outcome == "APPROVE" {
            addAuditEvent(pending.proposalId, approverId, "APPROVED", decision.reason ?: "");
        } else {
            markRejected(pending.proposalId, approverId, reason);
        }
        log:printInfo("approval decided", approvalId = approvalId, proposalId = pending.proposalId,
            outcome = decision.outcome, approverId = approverId);

        ai:Context context = new;
        context.set(CTX_EMPLOYEE_ID, pending.employeeId);
        context.set(CTX_SESSION_KEY, pending.sessionKey);
        context.set(CTX_TRAVELER_GRADE, traveler.grade);
        context.set(CTX_APPROVER_ID, approverId);
        ai:Resume resume = {decisions: {[approvalId]: humanDecision}};
        // The runtime claims the paused run before acting on the decision, so the approval is never put back:
        // if this run fails, the booking may already have happened. The proposal shows what was booked.
        string|ai:Error result = tripPlanner.run(query = resume, sessionId = pending.sessionKey, context = context);
        string sessionId = pending.sessionKey.substring(pending.employeeId.length() + 1);
        if result is ai:Error && result !is ai:ApprovalRequiredError {
            log:printError("resuming after the approval decision failed", 'error = result,
                approvalId = approvalId, proposalId = pending.proposalId);
            releaseSession(pending.sessionKey);
            return <http:InternalServerError>{
                body: <ErrorBody>{
                    message: string `The decision was recorded, but the planner failed afterwards. Check ` +
                        string `GET /travel/proposals/${pending.proposalId} for the booking status.`
                }
            };
        }
        ChatResponse|http:InternalServerError response = toChatResponse(sessionId = sessionId,
            sessionKey = pending.sessionKey, traveler = traveler, result = result);
        releaseSession(pending.sessionKey);
        return response;
    }

    # Returns a trip proposal with its policy result, booking status and audit trail.
    # + requesterId - The traveler or their manager
    # + proposalId - The proposal to read
    # + return - The proposal
    resource function get proposals/[string proposalId](@http:Header {name: "x-employee-id"} string requesterId)
            returns TripProposal|http:NotFound|http:Forbidden {
        TripProposal? proposal = getProposal(proposalId);
        if proposal is () {
            return <http:NotFound>{body: <ErrorBody>{message: "No proposal with that ID"}};
        }
        if requesterId != proposal.employeeId && requesterId != proposal.approverId {
            return <http:Forbidden>{body: <ErrorBody>{message: "Not your proposal"}};
        }
        return proposal;
    }
}

isolated function toChatResponse(string sessionId, string sessionKey, Employee traveler, string|ai:Error result)
        returns ChatResponse|http:InternalServerError {
    if result is string {
        return {sessionId, status: "COMPLETED", message: result, pendingApprovals: []};
    }
    if result is ai:ApprovalRequiredError {
        string requestedAt = nowIso();
        foreach ai:ApprovalRequest request in result.detail().requests {
            BookTripArgs|error args = request.arguments.cloneWithType();
            string proposalId = args is BookTripArgs ? args.proposalId : "";
            addPendingApproval({
                approvalId: request.id,
                sessionKey,
                proposalId,
                employeeId: traveler.employeeId,
                approverId: traveler.managerId,
                requestedAt
            });
            addAuditEvent(proposalId, traveler.employeeId, "SUBMITTED_FOR_APPROVAL", traveler.managerId);
        }
        ApprovalView[] views = from PendingApproval approval in pendingApprovalsInSession(sessionKey)
            select toApprovalView(approval);
        return {
            sessionId,
            status: "AWAITING_APPROVAL",
            message: string `Sent to your manager (${traveler.managerId}) for approval. ` +
                "Nothing is booked until they approve.",
            pendingApprovals: views
        };
    }
    log:printError("trip planner run failed", 'error = result, sessionKey = sessionKey);
    return <http:InternalServerError>{body: <ErrorBody>{message: "The trip planner could not complete the request"}};
}
