import ballerina/ai;
import ballerina/log;
import ballerina/time;
import ballerina/uuid;
import wso2/logistics_coordinator;

const CTX_EMPLOYEE_ID = "employeeId";
const CTX_SESSION_KEY = "sessionKey";
const CTX_APPROVER_ID = "approverId";
const CTX_TRAVELER_GRADE = "travelerGrade";

// ---- Employee directory: a stand-in for the HR system ----

final readonly & map<Employee> employeeDirectory = {
    "E1001": {
        employeeId: "E1001",
        givenName: "Alex",
        familyName: "Morgan",
        title: "mr",
        gender: "m",
        bornOn: "1990-04-12",
        email: "alex.morgan@example.com",
        phoneNumber: "+441632960001",
        grade: "staff",
        managerId: "M2001",
        homeAirport: "LHR",
        costCenter: "CC-ENG-410"
    },
    "M2001": {
        employeeId: "M2001",
        givenName: "Priya",
        familyName: "Raman",
        title: "ms",
        gender: "f",
        bornOn: "1984-09-30",
        email: "priya.raman@example.com",
        phoneNumber: "+441632960002",
        grade: "director",
        managerId: "V3001",
        homeAirport: "LHR",
        costCenter: "CC-ENG-400"
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

// ---- Proposals, approvals and sessions ----
// In-memory state. Swap for a database before running more than one replica: proposals, pending approvals
// and the agents' memory must survive restarts and be shared across instances.

isolated map<TripProposal> proposals = {};
isolated map<PendingApproval> pendingApprovals = {};
isolated map<boolean> activeSessions = {};

isolated function nowIso() returns string => time:utcToString(time:utcNow());

isolated function newProposalId() returns string => "TRIP-" + uuid:createType4AsString().substring(0, 8).toUpperAscii();

isolated function saveProposal(TripProposal proposal) {
    lock {
        proposals[proposal.proposalId] = proposal.clone();
    }
}

isolated function getProposal(string proposalId) returns TripProposal? {
    lock {
        return proposals[proposalId].clone();
    }
}

isolated function addAuditEvent(string proposalId, string actor, string action, string detail) {
    lock {
        TripProposal? proposal = proposals[proposalId];
        if proposal is TripProposal {
            proposal.auditTrail.push({at: nowIso(), actor, action, detail});
        }
    }
}

# Moves a proposal from PROPOSED to BOOKING. Returns `false` (and the current state) when the proposal was
# already handled, so a repeated approval cannot book twice.
isolated function beginBooking(string proposalId, string employeeId, string approverId)
        returns [TripProposal, boolean]|error {
    lock {
        TripProposal? proposal = proposals[proposalId];
        if proposal is () {
            return error(string `Unknown proposal '${proposalId}'`);
        }
        if proposal.employeeId != employeeId {
            return error("This proposal belongs to another employee");
        }
        if proposal.approverId != approverId {
            return error("This proposal can only be approved by the traveler's manager");
        }
        if proposal.status != "PROPOSED" {
            return [proposal.clone(), false];
        }
        proposal.status = "BOOKING";
        proposal.auditTrail.push({at: nowIso(), actor: approverId, action: "BOOKING_STARTED", detail: "Approved"});
        return [proposal.clone(), true];
    }
}

isolated function finishBooking(string proposalId, ProposalStatus status, BookingResult result)
        returns TripProposal|error {
    string detail = result.issues.length() == 0 ? "All bookings confirmed" : string:'join("; ", ...result.issues);
    lock {
        TripProposal? proposal = proposals[proposalId];
        if proposal is () {
            return error(string `Unknown proposal '${proposalId}'`);
        }
        proposal.status = status;
        proposal.booking = result.clone();
        proposal.auditTrail.push({at: nowIso(), actor: "system", action: status, detail});
        return proposal.clone();
    }
}

# Why a proposal cannot be submitted for approval, or nil when it can: it must be the traveler's, still
# PROPOSED, and not already waiting for a decision.
isolated function submissionProblem(string proposalId, Employee traveler) returns string? {
    TripProposal? proposal = getProposal(proposalId);
    if proposal is () || proposal.employeeId != traveler.employeeId || proposal.approverId != traveler.managerId {
        return string `Proposal '${proposalId}' is not one of this traveler's proposals, so it cannot be submitted.`;
    }
    if proposal.status != "PROPOSED" {
        return string `Proposal '${proposalId}' is already ${proposal.status}, so it cannot be submitted again.`;
    }
    if isAwaitingDecision(proposalId) {
        return string `Proposal '${proposalId}' is already waiting for the manager's decision.`;
    }
    return ();
}

isolated function markRejected(string proposalId, string employeeId, string approverId, string reason) {
    lock {
        TripProposal? proposal = proposals[proposalId];
        if proposal is TripProposal && proposal.employeeId == employeeId && proposal.approverId == approverId
                && proposal.status == "PROPOSED" {
            proposal.status = "REJECTED";
            proposal.auditTrail.push({at: nowIso(), actor: approverId, action: "REJECTED", detail: reason});
        }
    }
}

# Stores an approval request unless it is already pending. The agent returns undecided requests again after
# a decision on another request in the same batch, and those keep their original time.
# + return - `true` when the request is new
isolated function addPendingApproval(PendingApproval approval) returns boolean {
    lock {
        if pendingApprovals.hasKey(approval.approvalId) {
            return false;
        }
        pendingApprovals[approval.approvalId] = approval.clone();
        return true;
    }
}

isolated function isPendingApproval(string approvalId) returns boolean {
    lock {
        return pendingApprovals.hasKey(approvalId);
    }
}

isolated function isAwaitingDecision(string proposalId) returns boolean {
    lock {
        foreach PendingApproval approval in pendingApprovals {
            if approval.proposalId == proposalId {
                return true;
            }
        }
        return false;
    }
}

isolated function takePendingApproval(string approvalId) returns PendingApproval? {
    lock {
        if !pendingApprovals.hasKey(approvalId) {
            return ();
        }
        return pendingApprovals.remove(approvalId).clone();
    }
}

isolated function findPendingApproval(string approvalId) returns PendingApproval? {
    lock {
        return pendingApprovals[approvalId].clone();
    }
}

isolated function pendingApprovalsFor(string approverId) returns PendingApproval[] {
    lock {
        PendingApproval[] matches = from PendingApproval approval in pendingApprovals
            where approval.approverId == approverId
            select approval;
        return matches.clone();
    }
}

isolated function pendingApprovalsInSession(string sessionKey) returns PendingApproval[] {
    lock {
        PendingApproval[] matches = from PendingApproval approval in pendingApprovals
            where approval.sessionKey == sessionKey
            select approval;
        return matches.clone();
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

// ---- Booking ----

// Prices are re-checked before paying: offers expire (typically within 30 minutes) and prices can move between
// the employee's request and the manager's approval. Both are checked before either is booked, so a price rise
// on one never leaves the other booked on its own. The hotel is booked only after the flight order succeeds.

# Re-checks a flight offer's fare against the approved price.
isolated function checkFlightPrice(logistics_coordinator:FlightOffer flight)
        returns logistics_coordinator:CurrentFare|BookingIssue {
    logistics_coordinator:CurrentFare|error fare = logistics_coordinator:currentFare(flight.offerId);
    if fare is error {
        return {message: "Flight not booked: the offer could not be re-checked and may have expired. " +
            logistics_coordinator:describeError(fare)};
    }
    decimal ceiling = flight.totalAmount * (1d + priceTolerancePercent / 100d);
    if fare.currency != flight.currency || fare.amount > ceiling {
        return {message: string `Flight not booked: the fare changed from ${flight.currency} ${flight.totalAmount} ` +
            string `to ${fare.currency} ${fare.amount}, which needs re-approval`};
    }
    return fare;
}

# Quotes a hotel rate and checks the quote against the approved price, including the fees paid at the hotel,
# which the policy check counted. A quote reserves nothing and costs nothing, so a failed quote is always a plain
# failure.
isolated function checkHotelPrice(logistics_coordinator:HotelRate hotel)
        returns logistics_coordinator:HotelQuote|BookingIssue {
    logistics_coordinator:HotelQuote|error quote = logistics_coordinator:createHotelQuote(hotel.rateId);
    if quote is error {
        return {message: "Hotel not booked: the rate is no longer available. " +
            logistics_coordinator:describeError(quote)};
    }
    decimal ceiling = hotel.totalAmount * (1d + priceTolerancePercent / 100d);
    if quote.currency != hotel.currency || quote.amount > ceiling {
        return {message: string `Hotel not booked: the price changed from ${hotel.currency} ${hotel.totalAmount} ` +
            string `to ${quote.currency} ${quote.amount}, which needs re-approval`};
    }
    // When the fees were unknown at approval, the manager approved with a warning about them, so only known
    // fees are compared.
    decimal? approvedFee = hotel.dueAtAccommodationAmount;
    if approvedFee is decimal {
        decimal? quotedFee = quote.dueAtAccommodationAmount;
        string approvedFeeCurrency = hotel.dueAtAccommodationCurrency ?: hotel.currency;
        string quotedFeeCurrency = quote.dueAtAccommodationCurrency ?: quote.currency;
        if quotedFee is () || quotedFeeCurrency != approvedFeeCurrency
                || quotedFee > approvedFee * (1d + priceTolerancePercent / 100d) {
            string quotedText = quotedFee is () ? "unknown" : string `${quotedFeeCurrency} ${quotedFee}`;
            return {message: string `Hotel not booked: the fees payable at the hotel changed from ` +
                string `${approvedFeeCurrency} ${approvedFee} to ${quotedText}, which needs re-approval`};
        }
    }
    return quote;
}

isolated function orderFlight(logistics_coordinator:FlightOffer flight, logistics_coordinator:CurrentFare fare,
        Employee traveler) returns logistics_coordinator:FlightOrder|BookingIssue {
    logistics_coordinator:FlightOrder|error flightOrder = logistics_coordinator:createFlightOrder(
        offerId = flight.offerId, passengerId = flight.passengerId, traveler = toPassengerDetails(traveler),
        fare = fare);
    if flightOrder is error {
        string reason = logistics_coordinator:describeError(flightOrder);
        if logistics_coordinator:isOutcomeUnknown(flightOrder) {
            log:printError("flight order outcome unknown", offerId = flight.offerId, reason = reason);
            return {
                message: string `Flight booking outcome unknown: Duffel may have created the order for offer ` +
                    string `${flight.offerId}. Check the Duffel dashboard before trying again. ${reason}`,
                outcomeUnknown: true
            };
        }
        log:printError("flight order failed", offerId = flight.offerId, reason = reason);
        return {message: "Flight not booked: " + reason};
    }
    return flightOrder;
}

isolated function bookQuotedHotel(logistics_coordinator:HotelRate hotel, logistics_coordinator:HotelQuote quote,
        Employee traveler) returns logistics_coordinator:HotelBooking|BookingIssue {
    logistics_coordinator:HotelBooking|error booking = logistics_coordinator:createHotelBooking(
        quoteId = quote.quoteId, guest = toPassengerDetails(traveler));
    if booking is error {
        string reason = logistics_coordinator:describeError(booking);
        if logistics_coordinator:isOutcomeUnknown(booking) {
            log:printError("hotel booking outcome unknown", quoteId = quote.quoteId, reason = reason);
            return {
                message: string `Hotel booking outcome unknown: Duffel may have booked quote ${quote.quoteId}. ` +
                    string `Check the Duffel dashboard before trying again. ${reason}`,
                outcomeUnknown: true
            };
        }
        log:printError("hotel booking failed", rateId = hotel.rateId, reason = reason);
        return {message: "Hotel not booked: " + reason};
    }
    if booking.bookingId is () {
        log:printInfo("hotel booking confirmed without a booking record yet", quoteId = quote.quoteId);
    }
    return booking;
}
