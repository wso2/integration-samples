import wso2/policy_analyst;

# An employee record, as it would come from the HR system.
type Employee record {|
    string employeeId;
    string fullName;
    string email;
    string grade;
    # Nil for the top of the hierarchy, who has no approver
    string? managerId;
    string costCenter;
|};

# The subset of an employee record the agents are allowed to see.
type TravelerProfile record {|
    string employeeId;
    string fullName;
    string grade;
    string? managerId;
    string costCenter;
|};

# PREPARED: created, and not yet decided. STOPPED: approved, but the FCDO advice changed before the
# authorization was issued, so it needs a new request.
type RequestStatus "PREPARED"|"AUTHORIZED"|"REJECTED"|"STOPPED";

type AuditEvent record {|
    string at;
    string actor;
    string action;
    string detail;
|};

# The document the traveler takes to the travel desk to book the trip.
type TravelAuthorization record {|
    string authorizationId;
    string issuedAt;
    # The approvers, in the order they approved
    string[] approvedBy;
    # Conditions of travel, from the policy warnings and the FCDO advice at the time of issue
    string[] conditions;
|};

type TripRequest record {|
    string requestId;
    string employeeId;
    string purpose;
    string destination;
    string countryName;
    string countryCode;
    string startDate;
    string endDate;
    string? justification;
    policy_analyst:PolicyEvaluation policy;
    # Who must approve, in order: the traveler's manager, then their manager when a second approval is needed
    string[] approvalChain;
    RequestStatus status;
    string createdAt;
    TravelAuthorization? authorization;
    AuditEvent[] auditTrail;
|};

# Arguments of the gated `submitTripRequest` tool, as proposed by the LLM.
type SubmitArgs record {|
    string requestId;
|};

# A submission waiting for an approver's decision.
type PendingApproval record {|
    string approvalId;
    string sessionKey;
    string requestId;
    string employeeId;
    string[] approvalChain;
    # Index into `approvalChain` of the approver who decides next
    int stage;
    string requestedAt;
    # True while a decision is being processed, so the request stays reserved until it finishes
    boolean deciding = false;
|};

type ChatRequest record {|
    string sessionId;
    string message;
|};

type ChatStatus "COMPLETED"|"AWAITING_APPROVAL";

type ApprovalView record {|
    string approvalId;
    string requestedAt;
    # The approver who decides next
    string approverId;
    # 1 for the first approval, 2 for the second
    int stage;
    int stages;
    TripRequest? request;
|};

type ChatResponse record {|
    string sessionId;
    ChatStatus status;
    string message;
    ApprovalView[] pendingApprovals;
|};

type ApprovalDecision record {|
    "APPROVE"|"REJECT" outcome;
    string reason?;
|};

type ErrorBody record {|
    string message;
|};
