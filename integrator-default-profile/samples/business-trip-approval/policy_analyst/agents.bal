import ballerina/ai;

// Context entry the calling package sets to the traveler's employee grade.
const CTX_TRAVELER_GRADE = "travelerGrade";

# Checks a business trip against the company travel policy: FCDO advice, notice, trip length and public holidays, and whether a second approval is needed.
public isolated class PolicyAnalystAgent {
    *ai:FixedTypedAgent;

    private final ai:Agent agent;

    # Initializes the agent
    # + model - The AI model provider to use
    # + memory - The memory implementation to use
    public function init(ai:ModelProvider model, ai:Memory? memory = ()) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: string `Travel Policy Analyst`,
                instructions: string `You check a business trip against the company travel policy.
Call getTravelPolicy, then checkTripPolicy with the destination country, its two-letter code and the dates.
Report the result exactly: whether the trip can be submitted, every blocker, every reason it needs a second
approval, and every warning. If the FCDO advises against all but essential travel, say a justification is
needed and pass it to checkTripPolicy when you have one. Never change or soften the result.`
            },
            model = model,
            memory = memory,
            tools = [self.getTravelPolicy, self.checkTripPolicy],
            maxIter = 6
        );
    }

    public isolated function run(string|ai:Prompt query,
            string sessionId = "sessionId",
            ai:Context context = new) returns string|ai:Error {
        return self.agent.run(query, sessionId, context);
    }

    public isolated function trace(string|ai:Prompt query,
            string sessionId = "sessionId",
            ai:Context context = new) returns ai:Trace|ai:Error {
        return self.agent.run(query, sessionId, context);
    }

    # Returns the travel policy that applies to the traveler in this conversation.
    # + context - Request context (supplied by the runtime)
    # + return - The notice and trip-length rules for the traveler's grade
    @ai:AgentTool
    isolated function getTravelPolicy(ai:Context context) returns TravelPolicy|error {
        string grade = check context.getWithType(CTX_TRAVELER_GRADE);
        return getPolicy(grade);
    }

    # Checks a trip against the traveler's travel policy, using the current FCDO advice and the public holidays at the destination.
    # + context - Request context (supplied by the runtime)
    # + countryName - Destination country name in English, e.g. "Japan"
    # + countryCode - Two-letter destination country code, e.g. "JP"
    # + startDate - First day of the trip (YYYY-MM-DD)
    # + endDate - Last day of the trip (YYYY-MM-DD)
    # + justification - Why the trip is essential, when the FCDO advises against non-essential travel
    # + return - Whether the trip can be submitted, with blockers, second-approval reasons and warnings
    @ai:AgentTool
    isolated function checkTripPolicy(ai:Context context, string countryName, string countryCode, string startDate,
            string endDate, string? justification = ()) returns PolicyEvaluation|error {
        string grade = check context.getWithType(CTX_TRAVELER_GRADE);
        return checkTrip(grade, countryName, countryCode, startDate, endDate, justification);
    }
}
