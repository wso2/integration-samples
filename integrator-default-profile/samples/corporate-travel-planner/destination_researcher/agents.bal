import ballerina/ai;

# Briefs a business traveler on a destination: time zone, weather for the trip dates and UK FCDO travel advice.
public isolated class DestinationResearcherAgent {
    *ai:FixedTypedAgent;

    private final ai:Agent agent;

    # Initializes the agent
    # + model - The AI model provider to use
    # + memory - The memory implementation to use
    public function init(ai:ModelProvider model, ai:Memory? memory = ()) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: string `Destination Researcher`,
                instructions: string `You brief a business traveler on their destination for specific dates.
Use lookupLocation to get coordinates, country and time zone, then getWeatherOutlook for the trip dates and
getTravelAdvisory for the country. Reply with: time zone, a one-line weather summary (say whether it is a forecast
or last year's weather), the FCDO advice level, and any warnings that matter for the trip. Use only tool results.`
            },
            model = model,
            memory = memory,
            tools = [self.lookupLocation, self.getWeatherOutlook, self.getTravelAdvisory],
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

    # Finds a city or place and returns its coordinates, country and time zone.
    # + placeName - A city or place, e.g. "Kyoto" or "Austin, Texas"
    # + return - The best match
    @ai:AgentTool
    isolated function lookupLocation(string placeName) returns GeoLocation|error => geocode(placeName);

    # Returns the daily weather for the trip dates: a forecast when the trip is within about two weeks, otherwise the weather on the same dates last year as a guide.
    # + latitude - Latitude of the destination
    # + longitude - Longitude of the destination
    # + startDate - First day of the trip (YYYY-MM-DD)
    # + endDate - Last day of the trip (YYYY-MM-DD)
    # + return - Daily temperatures and rainfall
    @ai:AgentTool
    isolated function getWeatherOutlook(decimal latitude, decimal longitude, string startDate, string endDate)
            returns WeatherOutlook|error => weatherOutlook(latitude, longitude, startDate, endDate);

    # Returns the UK Foreign, Commonwealth & Development Office travel advice for a country, including whether it advises against all or non-essential travel.
    # + countryName - Country name in English, e.g. "Japan"
    # + return - The advice level and a summary of current warnings
    @ai:AgentTool
    isolated function getTravelAdvisory(string countryName) returns TravelAdvisory|error =>
        travelAdvisory(countryName);
}
