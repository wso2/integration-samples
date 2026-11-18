import ballerina/ai;

# Briefs a business traveler on a destination for specific dates: the location and time zone, the weather, and public holidays that may close offices.
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
Use lookupLocation to get the place, country, country code and time zone. Then call getWeatherOutlook and
getPublicHolidays for the trip dates. Reply with: the place and country with its country code, the time zone, a
one-line weather summary (say whether it is a forecast or the same dates in an earlier year), and the public
holidays during the trip, saying which are national and which are regional. Use only tool results.`
            },
            model = model,
            memory = memory,
            tools = [self.lookupLocation, self.getWeatherOutlook, self.getPublicHolidays],
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

    # Finds a city or place and returns its coordinates, country, country code and time zone.
    # + placeName - A city or place name, e.g. "Kyoto"
    # + countryName - The country, when the place name is used in several countries
    # + return - The best match
    @ai:AgentTool
    isolated function lookupLocation(string placeName, string? countryName = ()) returns GeoLocation|error =>
        geocode(placeName, countryName);

    # Returns the daily weather for the trip dates: a forecast when the trip is within about two weeks, otherwise the weather on the same dates in an earlier year as a guide.
    # + latitude - Latitude of the destination
    # + longitude - Longitude of the destination
    # + startDate - First day of the trip (YYYY-MM-DD)
    # + endDate - Last day of the trip (YYYY-MM-DD)
    # + return - Daily temperatures and rainfall
    @ai:AgentTool
    isolated function getWeatherOutlook(decimal latitude, decimal longitude, string startDate, string endDate)
            returns WeatherOutlook|error => weatherOutlook(latitude, longitude, startDate, endDate);

    # Returns the public holidays in a country between two dates, when offices may be closed.
    # + countryCode - Two-letter country code from lookupLocation, e.g. "JP"
    # + startDate - First day of the trip (YYYY-MM-DD)
    # + endDate - Last day of the trip (YYYY-MM-DD)
    # + return - National and regional public holidays during the trip
    @ai:AgentTool
    isolated function getPublicHolidays(string countryCode, string startDate, string endDate)
            returns PublicHoliday[]|error => publicHolidays(countryCode, startDate, endDate);
}
