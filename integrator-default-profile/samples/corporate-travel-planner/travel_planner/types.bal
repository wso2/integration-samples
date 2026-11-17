import wso2/logistics_coordinator;
import wso2/policy_analyst;

# An employee record, as it would come from the HR system. Personal details (date of birth, phone) are used
# only by the booking code and are never shown to the LLM.
type Employee record {|
    string employeeId;
    string givenName;
    string familyName;
    string title;
    string gender;
    string bornOn;
    string email;
    string phoneNumber;
    string grade;
    string managerId;
    string homeAirport;
    string costCenter;
|};

# The subset of an employee record the agents are allowed to see.
type TravelerProfile record {|
    string employeeId;
    string fullName;
    string grade;
    string homeAirport;
    string managerId;
    string costCenter;
|};

type ProposalStatus "PROPOSED"|"BOOKING"|"BOOKED"|"PARTIALLY_BOOKED"|"FAILED"|"REJECTED";

type AuditEvent record {|
    string at;
    string actor;
    string action;
    string detail;
|};

type BookingResult record {|
    string? flightOrderId = ();
    string? flightBookingReference = ();
    string? hotelBookingId = ();
    string? hotelBookingReference = ();
    string[] issues = [];
|};

type TripProposal record {|
    string proposalId;
    string employeeId;
    string approverId;
    string purpose;
    string destination;
    string destinationCountry;
    logistics_coordinator:FlightOffer? flight;
    logistics_coordinator:HotelRate? hotel;
    policy_analyst:PolicyEvaluation policy;
    ProposalStatus status;
    string createdAt;
    BookingResult? booking;
    AuditEvent[] auditTrail;
|};

# Arguments of the gated `bookTrip` tool, as proposed by the LLM.
type BookTripArgs record {|
    string proposalId;
|};

# A booking waiting for a manager's decision.
type PendingApproval record {|
    string approvalId;
    string sessionKey;
    string proposalId;
    string employeeId;
    string approverId;
    string requestedAt;
|};

type ChatRequest record {|
    string sessionId;
    string message;
|};

type ChatStatus "COMPLETED"|"AWAITING_APPROVAL";

type ApprovalView record {|
    string approvalId;
    string requestedAt;
    TripProposal? proposal;
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
