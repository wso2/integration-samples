import ballerina/ai;
import ballerina/log;
import wso2/destination_researcher;
import wso2/policy_analyst;
import wso2/travel_advisor;

// The specialists, each defined in its own library package. They are stateless: the planner sends each one a
// complete request, so no conversation history is carried between calls.
final destination_researcher:DestinationResearcherAgent destinationAgent = check new (modelProvider);
final travel_advisor:TravelAdvisorAgent advisorAgent = check new (modelProvider);
final policy_analyst:PolicyAnalystAgent policyAgent = check new (modelProvider);

// The planner keeps each conversation's history. The window is large because ai:ShortTermMemory trims by message
// count and can separate a tool call from its result, which the OpenAI API rejects; a trip request conversation
// stays well inside 200 messages.
final ai:ShortTermMemory plannerMemory = check new (check new ai:InMemoryShortTermMemoryStore(size = 200));

final ai:Agent tripPlanner = check new (
    systemPrompt = {
        role: string `Business Trip Planner`,
        instructions: string `You help an employee get a business trip approved. You do not book travel: an
approved request produces a travel authorization that the employee takes to the company travel desk.

1. Call getTravelerProfile first.
2. If the destination city and country, the dates or the business purpose are missing, ask for them.
3. Call researchDestination for the place and dates. Then call checkTravelAdvice for the country, and
   reviewPolicy with the country, its two-letter code and the dates.
4. Call createTripRequest. It checks the policy again and records the result the approvers will see. If the
   only blocker is a missing justification for essential travel, ask the employee for one, then create a new
   request with it. Other blockers cannot be fixed by a justification: explain them.
5. Present: purpose; dates; destination and time zone; weather; public holidays during the trip; FCDO advice
   level and key warnings; entry requirements; the policy result with every blocker, second-approval reason
   and warning; who must approve, in order; and the requestId. Ask whether to submit it.
6. Only after the employee clearly confirms, call submitTripRequest with the requestId. It waits for every
   approver in the chain.

Rules: use only facts that tools return. Never invent IDs or authorization numbers. Never say a trip is
authorized unless submitTripRequest returned status AUTHORIZED; then give the authorizationId and its
conditions. If it returns STOPPED, explain why and say a new request is needed. If a submission is rejected,
say who rejected it and give their reason.`
    },
    model = modelProvider,
    memory = plannerMemory,
    tools = [getTravelerProfile, researchDestination, checkTravelAdvice, reviewPolicy, createTripRequest,
        submitTripRequest],
    maxIter = 20
);

# Returns the profile of the traveler in this conversation: name, grade, manager and cost center.
# + context - Request context (supplied by the runtime)
# + return - The traveler's profile
@ai:AgentTool
isolated function getTravelerProfile(ai:Context context) returns TravelerProfile|error {
    Employee traveler = check currentTraveler(context);
    return toProfile(traveler);
}

# Asks the Destination Researcher for the location, country code, time zone, weather and public holidays for the trip.
# + context - Request context (supplied by the runtime)
# + request - The destination city and country, and the trip dates
# + return - The destination briefing
@ai:AgentTool
isolated function researchDestination(ai:Context context, string request) returns string|error {
    string sessionKey = check context.getWithType(CTX_SESSION_KEY);
    return destinationAgent.run(request, sessionKey + "/destination", context);
}

# Asks the Travel Advisor for the UK FCDO advice level, warnings, entry requirements, safety and health advice for a country.
# + context - Request context (supplied by the runtime)
# + request - The destination country, and anything specific to find out
# + return - The travel advice briefing
@ai:AgentTool
isolated function checkTravelAdvice(ai:Context context, string request) returns string|error {
    string sessionKey = check context.getWithType(CTX_SESSION_KEY);
    return advisorAgent.run(request, sessionKey + "/advice", context);
}

# Asks the Travel Policy Analyst whether the trip can be submitted, and whether it needs a second approval.
# + context - Request context (supplied by the runtime)
# + request - The destination country and its two-letter code, the dates, and any justification
# + return - The policy review
@ai:AgentTool
isolated function reviewPolicy(ai:Context context, string request) returns string|error {
    string sessionKey = check context.getWithType(CTX_SESSION_KEY);
    return policyAgent.run(request, sessionKey + "/policy", context);
}

# Creates a trip request. The policy check runs again here, so the request records the result the approvers will see, and who must approve it.
# + context - Request context (supplied by the runtime)
# + purpose - Business purpose of the trip
# + city - Destination city, e.g. "Tokyo"
# + countryName - Destination country name in English, e.g. "Japan"
# + startDate - First day of the trip (YYYY-MM-DD)
# + endDate - Last day of the trip (YYYY-MM-DD)
# + justification - Why the trip is essential, when the FCDO advises against non-essential travel
# + return - The request, including its requestId, policy result and approval chain
@ai:AgentTool
isolated function createTripRequest(ai:Context context, string purpose, string city, string countryName,
        string startDate, string endDate, string? justification = ()) returns TripRequest|error {
    Employee traveler = check currentTraveler(context);
    destination_researcher:GeoLocation place = check destination_researcher:geocode(city, countryName);
    string? countryCode = place.countryCode;
    if countryCode is () {
        return error(string `Could not find the country code for '${city}'`);
    }
    policy_analyst:PolicyEvaluation policy = check policy_analyst:checkTrip(traveler.grade, countryName, countryCode,
        startDate, endDate, justification);
    string[] approvalChain = approvalChainFor(traveler, policy.secondApprovalReasons.length() > 0);
    string createdAt = nowIso();
    TripRequest request = {
        requestId: newId("TRIP-"),
        employeeId: traveler.employeeId,
        purpose,
        destination: place.placeName,
        countryName,
        countryCode,
        startDate,
        endDate,
        justification,
        policy,
        approvalChain,
        status: "PREPARED",
        createdAt,
        authorization: (),
        auditTrail: [
            {
                at: createdAt,
                actor: traveler.employeeId,
                action: "PREPARED",
                detail: policy.submittable ? "Can be submitted" : string:'join("; ", ...policy.blockers)
            }
        ]
    };
    saveRequest(request);
    return request;
}

# Submits a trip request for approval. The conversation pauses until every approver in the chain decides; when all approve, the travel authorization is issued.
# + context - Request context (supplied by the runtime)
# + requestId - The requestId returned by createTripRequest
# + return - The request with its status, and the authorization when it is AUTHORIZED
@ai:AgentTool {requiresApproval: true}
isolated function submitTripRequest(ai:Context context, string requestId) returns TripRequest|error {
    string employeeId = check context.getWithType(CTX_EMPLOYEE_ID);
    // Set only when the last approver's decision resumes the run (see the approvals resource).
    string|ai:Error approverId = context.getWithType(CTX_APPROVER_ID);
    if approverId is ai:Error {
        return error("The trip needs approval before it is authorized");
    }
    TripRequest request = check authorizeRequest(requestId, employeeId, approverId);
    log:printInfo("trip request decided", requestId = requestId, status = request.status, approverId = approverId);
    return request;
}
