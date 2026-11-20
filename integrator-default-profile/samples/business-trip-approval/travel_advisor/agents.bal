import ballerina/ai;

# Briefs a business traveler on the UK FCDO travel advice for a country: the advice level and warnings, entry requirements, safety and security, and health.
public isolated class TravelAdvisorAgent {
    *ai:FixedTypedAgent;

    private final ai:Agent agent;

    # Initializes the agent
    # + model - The AI model provider to use
    # + memory - The memory implementation to use
    public function init(ai:ModelProvider model, ai:Memory? memory = ()) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: string `Travel Advisor`,
                instructions: string `You brief a business traveler on the UK FCDO travel advice for a country.
Call getTravelAdvice first, then getEntryRequirements, getSafetyAndSecurity and getHealthAdvice.
Reply with: the advice level and any warnings; the entry requirements (passport validity, visas, and anything
to arrange before travel), noting that the FCDO writes them for British passport holders; the safety and health
points that matter for a short business trip; and the GOV.UK page. Keep it short. Use only tool results.`
            },
            model = model,
            memory = memory,
            tools = [self.getTravelAdvice, self.getEntryRequirements, self.getSafetyAndSecurity, self.getHealthAdvice],
            maxIter = 8
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

    # Returns the UK FCDO advice level for a country, including whether it advises against all or non-essential travel, and its current warnings.
    # + countryName - Country name in English, e.g. "Japan"
    # + return - The advice level and a summary of current warnings
    @ai:AgentTool
    isolated function getTravelAdvice(string countryName) returns TravelAdvisory|error =>
        travelAdvisory(countryName);

    # Returns the FCDO entry requirements for a country: passport validity, visas and other conditions of entry.
    # + countryName - Country name in English
    # + return - The entry requirements
    @ai:AgentTool
    isolated function getEntryRequirements(string countryName) returns AdviceSection|error =>
        adviceSection(countryName, "Entry requirements");

    # Returns the FCDO safety and security advice for a country.
    # + countryName - Country name in English
    # + return - The safety and security advice
    @ai:AgentTool
    isolated function getSafetyAndSecurity(string countryName) returns AdviceSection|error =>
        adviceSection(countryName, "Safety and security");

    # Returns the FCDO health advice for a country, such as vaccinations and health risks.
    # + countryName - Country name in English
    # + return - The health advice
    @ai:AgentTool
    isolated function getHealthAdvice(string countryName) returns AdviceSection|error =>
        adviceSection(countryName, "Health");
}
