import ballerina/ai;
import ballerina/log;
import wso2/destination_researcher;
import wso2/logistics_coordinator;
import wso2/policy_analyst;

// The specialists, each defined in its own library package. They are stateless: the planner sends each one a
// complete request, so no conversation history is carried between calls.
final destination_researcher:DestinationResearcherAgent destinationAgent = check new (modelProvider);
final logistics_coordinator:LogisticsCoordinatorAgent logisticsAgent = check new (modelProvider);
final policy_analyst:PolicyAnalystAgent policyAgent = check new (modelProvider);

// The planner keeps each conversation's history. The window is large because ai:ShortTermMemory trims by message
// count and can separate a tool call from its result, which the OpenAI API rejects; a trip-planning conversation
// stays well inside 200 messages.
final ai:ShortTermMemory plannerMemory = check new (check new ai:InMemoryShortTermMemoryStore(size = 200));

final ai:Agent tripPlanner = check new (
    systemPrompt = {
        role: string `Corporate Travel Planner`,
        instructions: string `You help an employee plan and book a business trip.

1. Call getTravelerProfile first to learn the traveler's home airport and grade.
2. If the destination, dates or business purpose are missing, ask for them before searching.
3. Call researchDestination and arrangeLogistics. Ask logistics for flights from the home airport and a hotel
   for the stay dates, in the cabin the policy allows (check with reviewPolicyAndBudget if unsure).
4. Call reviewPolicyAndBudget with the candidate offerIds and rateIds, and pick its recommendation.
5. Call createTripProposal with the chosen IDs. Then present: purpose; weather; FCDO advice; flight; hotel;
   total in USD; policy result with every violation and warning; and the proposalId. Ask whether to submit
   it for manager approval.
6. Only after the employee clearly confirms, call bookTrip with the proposalId. This waits for the manager's
   approval; the booking happens only once they approve.

Rules: use only facts that tools return. Never invent prices, IDs or booking references. Never say a trip is
booked unless bookTrip returned status BOOKED, and give any issues it lists. If bookTrip returns NEEDS_REVIEW,
say the booking may or may not have gone through, give its issues, and say it must be checked with Duffel
before anyone tries again.
If a proposal breaks policy, say so plainly; it can still be submitted, and the manager decides.
If an offer has expired, search again and create a new proposal.
If the manager rejects a booking, tell the employee it was submitted and rejected, and give the manager's reason.
Hotels marked isTestInventory are Duffel test-mode stand-ins for hotels at the destination: use them, and tell the
employee they are test inventory.`
    },
    model = modelProvider,
    memory = plannerMemory,
    tools = [getTravelerProfile, researchDestination, arrangeLogistics, reviewPolicyAndBudget, createTripProposal,
        bookTrip],
    maxIter = 20
);

# Returns the profile of the traveler in this conversation: name, grade, home airport and manager.
# + context - Request context (supplied by the runtime)
# + return - The traveler's profile
@ai:AgentTool
isolated function getTravelerProfile(ai:Context context) returns TravelerProfile|error {
    Employee traveler = check currentTraveler(context);
    return toProfile(traveler);
}

# Asks the Destination Researcher for weather, time zone and FCDO travel advice for the trip.
# + context - Request context (supplied by the runtime)
# + request - The destination, dates and anything specific to find out
# + return - The destination briefing
@ai:AgentTool
isolated function researchDestination(ai:Context context, string request) returns string|error {
    string sessionKey = check context.getWithType(CTX_SESSION_KEY);
    return destinationAgent.run(request, sessionKey + "/destination", context);
}

# Asks the Logistics Coordinator for flight and hotel options with their offerIds and rateIds.
# + context - Request context (supplied by the runtime)
# + request - Origin, destination, dates, cabin, and the meeting location if known
# + return - Flight and hotel options
@ai:AgentTool
isolated function arrangeLogistics(ai:Context context, string request) returns string|error {
    string sessionKey = check context.getWithType(CTX_SESSION_KEY);
    return logisticsAgent.run(request, sessionKey + "/logistics", context);
}

# Asks the Policy and Budget Analyst to check candidate options against the travel policy.
# + context - Request context (supplied by the runtime)
# + request - The destination country and the candidate offerIds and rateIds to check
# + return - The policy review and recommendation
@ai:AgentTool
isolated function reviewPolicyAndBudget(ai:Context context, string request) returns string|error {
    string sessionKey = check context.getWithType(CTX_SESSION_KEY);
    return policyAgent.run(request, sessionKey + "/policy", context);
}

# Creates a trip proposal from a chosen flight offer and/or hotel rate. The policy check runs again here, so the proposal records the result the manager will see.
# + context - Request context (supplied by the runtime)
# + purpose - Business purpose of the trip
# + destination - Destination city
# + destinationCountry - Destination country name, e.g. "Japan"
# + flightOfferId - The chosen offerId, if a flight is needed
# + hotelRateId - The chosen rateId, if a hotel is needed
# + return - The proposal, including its proposalId and policy result
@ai:AgentTool
isolated function createTripProposal(ai:Context context, string purpose, string destination,
        string destinationCountry, string? flightOfferId = (), string? hotelRateId = ()) returns TripProposal|error {
    if flightOfferId is () && hotelRateId is () {
        return error("A proposal needs a flight offer, a hotel rate, or both");
    }
    Employee traveler = check currentTraveler(context);
    logistics_coordinator:FlightOffer? flight = flightOfferId is string
        ? check logistics_coordinator:findFlightOffer(flightOfferId) : ();
    logistics_coordinator:HotelRate? hotel = hotelRateId is string
        ? check logistics_coordinator:findHotelRate(hotelRateId) : ();
    policy_analyst:PolicyEvaluation policy = check policy_analyst:evaluateTrip(traveler.grade, flight, hotel,
        policy_analyst:adviceLevelFor(destinationCountry));
    string createdAt = nowIso();
    TripProposal proposal = {
        proposalId: newProposalId(),
        employeeId: traveler.employeeId,
        approverId: traveler.managerId,
        purpose,
        destination,
        destinationCountry,
        flight,
        hotel,
        policy,
        status: "PROPOSED",
        createdAt,
        booking: (),
        auditTrail: [
            {
                at: createdAt,
                actor: traveler.employeeId,
                action: "PROPOSED",
                detail: policy.compliant ? "Within policy" : string:'join("; ", ...policy.violations)
            }
        ]
    };
    saveProposal(proposal);
    return proposal;
}

# Books the flight and hotel in a trip proposal. Needs manager approval, so the conversation pauses until they decide.
# + context - Request context (supplied by the runtime)
# + proposalId - The proposalId returned by createTripProposal
# + return - The proposal with its booking status and references
@ai:AgentTool {requiresApproval: true}
isolated function bookTrip(ai:Context context, string proposalId) returns TripProposal|error {
    string employeeId = check context.getWithType(CTX_EMPLOYEE_ID);
    // Set only when a manager's decision resumes the run (see the approvals resource).
    string|ai:Error approverValue = context.getWithType(CTX_APPROVER_ID);
    if approverValue is ai:Error {
        return error("Booking needs the manager's approval");
    }
    string approverId = approverValue;

    [TripProposal, boolean] [proposal, started] = check beginBooking(proposalId, employeeId, approverId);
    if !started {
        // Already booked, failed or rejected: report the current state instead of booking twice.
        return proposal;
    }
    Employee traveler = check getEmployee(employeeId);
    BookingResult result = {};
    logistics_coordinator:FlightOffer? flight = proposal.flight;
    logistics_coordinator:HotelRate? hotel = proposal.hotel;

    // Check both prices first, so a price rise on one books neither.
    logistics_coordinator:CurrentFare|BookingIssue? fare = flight is () ? () : checkFlightPrice(flight);
    logistics_coordinator:HotelQuote|BookingIssue? quote = hotel is () ? () : checkHotelPrice(hotel);
    if fare is BookingIssue || quote is BookingIssue {
        if fare is BookingIssue {
            result.issues.push(fare.message);
        }
        if quote is BookingIssue {
            result.issues.push(quote.message);
        }
        result.issues.push("Nothing was booked.");
        log:printInfo("trip booking stopped before payment", proposalId = proposalId, approverId = approverId);
        return finishBooking(proposalId, "FAILED", result);
    }

    // Book the flight first. If it fails, the hotel is not booked, so a hotel is never left without its flight.
    if flight is logistics_coordinator:FlightOffer && fare is logistics_coordinator:CurrentFare {
        logistics_coordinator:FlightOrder|BookingIssue flightOrder = orderFlight(flight, fare, traveler);
        if flightOrder is BookingIssue {
            result.issues.push(flightOrder.message);
            if hotel is logistics_coordinator:HotelRate {
                result.issues.push("Hotel not booked, because the flight was not booked.");
            }
            return endBooking(proposalId, approverId, flightOrder.outcomeUnknown ? "NEEDS_REVIEW" : "FAILED", result);
        }
        result.flightOrderId = flightOrder.orderId;
        result.flightBookingReference = flightOrder.bookingReference;
    }
    if hotel is logistics_coordinator:HotelRate && quote is logistics_coordinator:HotelQuote {
        logistics_coordinator:HotelBooking|BookingIssue booking = bookQuotedHotel(hotel, quote, traveler);
        if booking is BookingIssue {
            result.issues.push(booking.message);
            ProposalStatus status = booking.outcomeUnknown ? "NEEDS_REVIEW"
                : flight is () ? "FAILED" : "PARTIALLY_BOOKED";
            return endBooking(proposalId, approverId, status, result);
        }
        result.hotelBookingId = booking.bookingId;
        result.hotelBookingReference = booking.reference;
        if booking.bookingId is () {
            result.issues.push("Duffel confirmed the hotel booking, but its record can take a few hours to appear. " +
                "The booking ID and reference will be in the Duffel dashboard then. Do not book the hotel again.");
        }
    }
    return endBooking(proposalId, approverId, "BOOKED", result);
}

isolated function endBooking(string proposalId, string approverId, ProposalStatus status, BookingResult result)
        returns TripProposal|error {
    log:printInfo("trip booking finished", proposalId = proposalId, status = status, approverId = approverId);
    return finishBooking(proposalId, status, result);
}
