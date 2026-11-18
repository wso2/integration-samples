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
                body: <ErrorBody>{message: "This conversation is waiting for approval. Start a new session."}
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

    # Lists the trip requests waiting for the caller's decision.
    # + approverId - The calling approver
    # + return - Pending approvals with the full request and policy result
    resource function get approvals(@http:Header {name: "x-employee-id"} string approverId) returns ApprovalView[] {
        return from PendingApproval approval in pendingApprovalsFor(approverId)
            select toApprovalView(approval);
    }

    # Approves or rejects a pending trip request. When a second approval is needed, an approval hands the request
    # to the next approver; the last decision resumes the paused conversation.
    # + approverId - The calling approver
    # + approvalId - The approval to decide
    # + decision - APPROVE or REJECT, with an optional reason
    # + return - The planner's reply after the decision, or the approval now waiting for the next approver
    resource function post approvals/[string approvalId](@http:Header {name: "x-employee-id"} string approverId,
            ApprovalDecision decision)
            returns ChatResponse|http:NotFound|http:Forbidden|http:Conflict|http:InternalServerError {
        PendingApproval? found = findPendingApproval(approvalId);
        if found is () {
            return <http:NotFound>{body: <ErrorBody>{message: "No pending approval with that ID"}};
        }
        if found.approvalChain[found.stage] != approverId || found.employeeId == approverId {
            return <http:Forbidden>{body: <ErrorBody>{message: "This approval is waiting for another approver"}};
        }
        if !tryAcquireSession(found.sessionKey) {
            return <http:Conflict>{body: <ErrorBody>{message: "This conversation is busy; try again shortly"}};
        }
        PendingApproval? claimed = claimApproval(approvalId);
        if claimed is () || claimed.approvalChain[claimed.stage] != approverId {
            releaseSession(found.sessionKey);
            return <http:Conflict>{body: <ErrorBody>{message: "This approval was already decided"}};
        }
        PendingApproval pending = claimed;
        Employee|error traveler = getEmployee(pending.employeeId);
        if traveler is error {
            completeApproval(approvalId);
            releaseSession(pending.sessionKey);
            return <http:InternalServerError>{body: <ErrorBody>{message: traveler.message()}};
        }
        string sessionId = pending.sessionKey.substring(pending.employeeId.length() + 1);
        int stages = pending.approvalChain.length();
        string reason = decision.reason ?: "Rejected by approver";

        readonly & ai:HumanDecision humanDecision;
        TripRequest? current = getRequest(pending.requestId);
        if current is () || current.status != "PREPARED" {
            // The request changed since it was submitted, so this approval is out of date. Close it without
            // recording a decision on the request.
            string state = current is () ? "gone" : current.status;
            humanDecision = {
                outcome: ai:REJECT,
                reason: string `Request '${pending.requestId}' is already ${state}, so this approval is out of ` +
                    "date. Nothing was changed."
            };
            log:printWarn("approval is out of date", approvalId = approvalId, requestId = pending.requestId,
                status = state);
        } else if decision.outcome == "REJECT" {
            humanDecision = {outcome: ai:REJECT, reason: string `Rejected by ${approverId}: ${reason}`};
            markRejected(pending.requestId, approverId, reason);
        } else if pending.stage + 1 < stages {
            // Not the last approver: record the approval and hand the request to the next one. The conversation
            // stays paused.
            addAuditEvent(pending.requestId, approverId, "APPROVED",
                string `Approval ${pending.stage + 1} of ${stages}` + (decision.reason is string ? ": " + reason : ""));
            PendingApproval? next = advanceApproval(approvalId);
            releaseSession(pending.sessionKey);
            log:printInfo("approval passed to the next approver", approvalId = approvalId,
                requestId = pending.requestId, approverId = approverId);
            string nextApprover = pending.approvalChain[pending.stage + 1];
            ApprovalView[] views = [];
            if next is PendingApproval {
                views.push(toApprovalView(next));
            }
            return <ChatResponse>{
                sessionId,
                status: "AWAITING_APPROVAL",
                message: string `Approved. The request now needs approval from ${nextApprover}: ` +
                    string:'join("; ", ...current.policy.secondApprovalReasons),
                pendingApprovals: views
            };
        } else {
            humanDecision = {outcome: ai:APPROVE};
            addAuditEvent(pending.requestId, approverId, "APPROVED",
                string `Approval ${pending.stage + 1} of ${stages}` + (decision.reason is string ? ": " + reason : ""));
        }
        log:printInfo("approval decided", approvalId = approvalId, requestId = pending.requestId,
            outcome = decision.outcome, approverId = approverId);

        ai:Context context = new;
        context.set(CTX_EMPLOYEE_ID, pending.employeeId);
        context.set(CTX_SESSION_KEY, pending.sessionKey);
        context.set(CTX_TRAVELER_GRADE, traveler.grade);
        context.set(CTX_APPROVER_ID, approverId);
        ai:Resume resume = {decisions: {[approvalId]: humanDecision}};
        // The runtime claims the paused run before acting on the decision, so the approval is never put back:
        // if this run fails, the authorization may already have been issued. The request shows its state.
        string|ai:Error result = tripPlanner.run(query = resume, sessionId = pending.sessionKey, context = context);
        completeApproval(approvalId);
        if result is ai:Error && result !is ai:ApprovalRequiredError {
            log:printError("resuming after the approval decision failed", 'error = result,
                approvalId = approvalId, requestId = pending.requestId);
            releaseSession(pending.sessionKey);
            return failedAfterDecision(pending.requestId);
        }
        ChatResponse|http:InternalServerError response = toChatResponse(sessionId = sessionId,
            sessionKey = pending.sessionKey, traveler = traveler, result = result);
        releaseSession(pending.sessionKey);
        return response is http:InternalServerError ? failedAfterDecision(pending.requestId) : response;
    }

    # Returns a trip request with its policy result, approval chain, authorization and audit trail.
    # + requesterId - The traveler or one of the request's approvers
    # + requestId - The request to read
    # + return - The request
    resource function get requests/[string requestId](@http:Header {name: "x-employee-id"} string requesterId)
            returns TripRequest|http:NotFound|http:Forbidden {
        TripRequest? request = getRequest(requestId);
        if request is () {
            return <http:NotFound>{body: <ErrorBody>{message: "No trip request with that ID"}};
        }
        if !canView(request, requesterId) {
            return <http:Forbidden>{body: <ErrorBody>{message: "Not your trip request"}};
        }
        return request;
    }
}

isolated function toChatResponse(string sessionId, string sessionKey, Employee traveler, string|ai:Error result)
        returns ChatResponse|http:InternalServerError {
    if result is string {
        return {sessionId, status: "COMPLETED", message: result, pendingApprovals: []};
    }
    if result is ai:ApprovalRequiredError {
        // Approvals already pending were checked when first submitted; the agent returns them again, undecided,
        // after a decision on another approval in the same batch.
        string requestedAt = nowIso();
        PendingApproval[] submissions = from ai:ApprovalRequest request in result.detail().requests
            where !isPendingApproval(request.id)
            let string requestId = requestIdOf(request)
            let TripRequest? tripRequest = getRequest(requestId)
            select {
                approvalId: request.id,
                sessionKey,
                requestId,
                employeeId: traveler.employeeId,
                approvalChain: tripRequest is TripRequest ? tripRequest.approvalChain : [],
                stage: 0,
                requestedAt
            };
        map<string> problems = reserveSubmissions(submissions, traveler);
        if problems.length() > 0 {
            return rejectSubmissions(sessionId, sessionKey, traveler, submissions, problems);
        }
        ApprovalView[] views = from PendingApproval approval in pendingApprovalsInSession(sessionKey)
            select toApprovalView(approval);
        string[] approvers = views.length() > 0 && views[0].request is TripRequest
            ? (<TripRequest>views[0].request).approvalChain : [];
        return {
            sessionId,
            status: "AWAITING_APPROVAL",
            message: string `Sent for approval to ${string:'join(" then ", ...approvers)}. ` +
                "Nothing is authorized until every approver approves.",
            pendingApprovals: views
        };
    }
    log:printError("trip planner run failed", 'error = result, sessionKey = sessionKey);
    return <http:InternalServerError>{body: <ErrorBody>{message: "The trip planner could not complete the request"}};
}

isolated function requestIdOf(ai:ApprovalRequest request) returns string {
    SubmitArgs|error args = request.arguments.cloneWithType();
    return args is SubmitArgs ? args.requestId : "";
}

// The model chose which request to submit, so check it before any approver sees it. A submission that cannot be
// made (another traveler's request, one already decided or waiting, or one the policy blocks) is rejected at
// once, with the rest of its batch, so the conversation does not stay paused and no approver sees it.
isolated function rejectSubmissions(string sessionId, string sessionKey, Employee traveler,
        PendingApproval[] submissions, map<string> problems) returns ChatResponse|http:InternalServerError {
    log:printWarn("refused to submit trip requests", employeeId = traveler.employeeId,
        problems = problems.toArray());
    map<ai:HumanDecision> decisions = {};
    foreach PendingApproval submission in submissions {
        decisions[submission.approvalId] = {
            outcome: ai:REJECT,
            reason: problems[submission.approvalId]
                ?: "Submitted together with a request that could not be submitted. Submit it again on its own."
        };
    }
    ai:Context context = new;
    context.set(CTX_EMPLOYEE_ID, traveler.employeeId);
    context.set(CTX_SESSION_KEY, sessionKey);
    context.set(CTX_TRAVELER_GRADE, traveler.grade);
    ai:Resume resume = {decisions: decisions.cloneReadOnly()};
    string|ai:Error next = tripPlanner.run(query = resume, sessionId = sessionKey, context = context);
    return toChatResponse(sessionId = sessionId, sessionKey = sessionKey, traveler = traveler, result = next);
}

// Points the approver at the request when the planner fails after a decision.
isolated function failedAfterDecision(string requestId) returns http:InternalServerError => {
    body: <ErrorBody>{
        message: string `The decision was recorded, but the planner failed afterwards. Check ` +
            string `GET /travel/requests/${requestId} for the request's status.`
    }
};
