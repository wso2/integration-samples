import ballerina/ai;
import wso2/logistics_coordinator;

// Context entry the calling package sets to the traveler's employee grade.
const CTX_TRAVELER_GRADE = "travelerGrade";

# Checks candidate flights and hotels against the company travel policy and recommends the cheapest compliant combination.
public isolated class PolicyAnalystAgent {
    *ai:FixedTypedAgent;

    private final ai:Agent agent;

    # Initializes the agent
    # + model - The AI model provider to use
    # + memory - The memory implementation to use
    public function init(ai:ModelProvider model, ai:Memory? memory = ()) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: string `Policy and Budget Analyst`,
                instructions: string `You check trip options against the company travel policy.
Call getTravelPolicy first. Then call checkTripPolicy for each candidate pair of flightOfferId and hotelRateId you
are given. Recommend the cheapest combination that complies. If none complies, recommend the closest one and list
exactly which rules it breaks. Use convertToCurrency for budget questions. Report totals in USD. Quote IDs exactly
and never invent numbers.`
            },
            model = model,
            memory = memory,
            tools = [self.getTravelPolicy, self.checkTripPolicy, self.convertToCurrency],
            maxIter = 10
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
    # + return - Cabin rules, hotel and trip caps, and advance-booking rules
    @ai:AgentTool
    isolated function getTravelPolicy(ai:Context context) returns TravelPolicy|error {
        string grade = check context.getWithType(CTX_TRAVELER_GRADE);
        return getPolicy(grade);
    }

    # Checks a candidate flight and/or hotel rate against the traveler's travel policy, including the FCDO advice for the destination country. Totals are in USD.
    # + context - Request context (supplied by the runtime)
    # + destinationCountry - Destination country name, e.g. "Japan"
    # + flightOfferId - An offerId from a flight search, if a flight is needed
    # + hotelRateId - A rateId from getHotelRates, if a hotel is needed
    # + return - Whether the combination complies, with any violations and warnings
    @ai:AgentTool
    isolated function checkTripPolicy(ai:Context context, string destinationCountry, string? flightOfferId = (),
            string? hotelRateId = ()) returns PolicyEvaluation|error {
        string grade = check context.getWithType(CTX_TRAVELER_GRADE);
        logistics_coordinator:FlightOffer? flight = flightOfferId is string
            ? check logistics_coordinator:findFlightOffer(flightOfferId) : ();
        logistics_coordinator:HotelRate? hotel = hotelRateId is string
            ? check logistics_coordinator:findHotelRate(hotelRateId) : ();
        return evaluateTrip(grade, flight, hotel, adviceLevelFor(destinationCountry));
    }

    # Converts an amount between currencies using the latest European Central Bank reference rate.
    # + amount - The amount to convert
    # + fromCurrency - ISO 4217 code of the amount, e.g. "GBP"
    # + toCurrency - ISO 4217 code to convert to, e.g. "USD"
    # + return - The converted amount and the rate used
    @ai:AgentTool
    isolated function convertToCurrency(decimal amount, string fromCurrency, string toCurrency)
            returns CurrencyConversion|error => convertCurrency(amount, fromCurrency, toCurrency);
}
