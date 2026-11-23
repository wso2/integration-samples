import wso2/policy_analyst;

# An employee record, as it would come from the HR system.
type Employee record {|
    # The employee's ID, e.g. "E1001"
    string employeeId;
    # The employee's full name
    string fullName;
    # The employee's work email address
    string email;
    # The employee's grade, which selects the travel policy: "staff", "director" or "vp"
    string grade;
    # Nil for the top of the hierarchy, who has no approver
    string? managerId;
    # The cost center the employee's travel is charged to
    string costCenter;
|};

# The subset of an employee record the agents are allowed to see.
type TravelerProfile record {|
    # The traveler's employee ID
    string employeeId;
    # The traveler's full name
    string fullName;
    # The traveler's grade, which selects the travel policy
    string grade;
    # The traveler's manager, who approves first; nil at the top of the hierarchy
    string? managerId;
    # The cost center the trip is charged to
    string costCenter;
|};

# PREPARED: created, and not yet decided. STOPPED: approved, but the FCDO advice changed before the
# authorization was issued, so it needs a new request.
type RequestStatus "PREPARED"|"AUTHORIZED"|"REJECTED"|"STOPPED";

# One entry in a trip request's audit trail.
type AuditEvent record {|
    # When it happened (ISO 8601, UTC)
    string at;
    # The employee ID of whoever acted
    string actor;
    # What happened, e.g. "PREPARED", "SUBMITTED_FOR_APPROVAL", "APPROVED" or "AUTHORIZED"
    string action;
    # A short description for people reading the trail
    string detail;
|};

# The document the traveler takes to the travel desk to book the trip.
type TravelAuthorization record {|
    # The authorization's ID, e.g. "TA-34D81D47"
    string authorizationId;
    # When it was issued (ISO 8601, UTC)
    string issuedAt;
    # The approvers, in the order they approved
    string[] approvedBy;
    # Conditions of travel, from the policy warnings and the FCDO advice at the time of issue
    string[] conditions;
|};

# A trip request the planner prepared, with the policy result the approvers see.
type TripRequest record {|
    # The request's ID, e.g. "TRIP-35FD3195"
    string requestId;
    # The traveler's employee ID
    string employeeId;
    # The business purpose of the trip
    string purpose;
    # The destination city, as the geocoder names it
    string destination;
    # The destination country's English name
    string countryName;
    # The destination country's two-letter ISO 3166-1 code
    string countryCode;
    # The first day of the trip (YYYY-MM-DD)
    string startDate;
    # The last day of the trip (YYYY-MM-DD)
    string endDate;
    # Why the trip is essential, when the FCDO advises against all but essential travel
    string? justification;
    # The result of the policy check when the request was prepared
    policy_analyst:PolicyEvaluation policy;
    # Who must approve, in order: the traveler's manager, then their manager when a second approval is needed
    string[] approvalChain;
    # Where the request stands
    RequestStatus status;
    # When the request was prepared (ISO 8601, UTC)
    string createdAt;
    # The travel authorization, once every approver has approved
    TravelAuthorization? authorization;
    # Everything that happened to the request, oldest first
    AuditEvent[] auditTrail;
|};

# Arguments of the gated `submitTripRequest` tool, as proposed by the LLM.
type SubmitArgs record {|
    # The trip request to submit
    string requestId;
|};

# A submission waiting for an approver's decision.
type PendingApproval record {|
    # The approval's ID, used in `POST /travel/approvals/{approvalId}`
    string approvalId;
    # The traveler's conversation ("employeeId/sessionId"), whose paused run the decision resumes
    string sessionKey;
    # The trip request waiting for the decision
    string requestId;
    # The traveler's employee ID
    string employeeId;
    # Who must approve, in order
    string[] approvalChain;
    # Index into `approvalChain` of the approver who decides next
    int stage;
    # When the request was submitted (ISO 8601, UTC)
    string requestedAt;
    # True while a decision is being processed, so the request stays reserved until it finishes
    boolean deciding = false;
|};

# A message from the employee to the trip planner.
type ChatRequest record {|
    # The conversation's ID, chosen by the client; the planner remembers the conversation per employee
    string sessionId;
    # The employee's message
    string message;
|};

type ChatStatus "COMPLETED"|"AWAITING_APPROVAL";

# A trip request waiting for an approver, as the approval API shows it.
type ApprovalView record {|
    # The approval's ID, used in `POST /travel/approvals/{approvalId}`
    string approvalId;
    # When the request was submitted (ISO 8601, UTC)
    string requestedAt;
    # The approver who decides next
    string approverId;
    # 1 for the first approval, 2 for the second
    int stage;
    # How many approvals the request needs: 1 or 2
    int stages;
    # The trip request, with its policy result
    TripRequest? request;
|};

# The trip planner's reply.
type ChatResponse record {|
    # The conversation's ID
    string sessionId;
    # AWAITING_APPROVAL when the planner submitted a request and waits for an approver, otherwise COMPLETED
    ChatStatus status;
    # The planner's reply, in Markdown
    string message;
    # The approvals the reply is waiting for, if any
    ApprovalView[] pendingApprovals;
|};

# An approver's decision on a trip request.
type ApprovalDecision record {|
    # Whether the approver approves or rejects the request
    "APPROVE"|"REJECT" outcome;
    # Why, shown to the traveler; most useful with a rejection
    string reason?;
|};

# The body of an error response.
type ErrorBody record {|
    # What went wrong
    string message;
|};
