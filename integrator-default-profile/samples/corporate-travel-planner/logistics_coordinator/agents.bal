import ballerina/ai;
import wso2/destination_researcher;

# Finds flights and a hotel for a business trip through Duffel, returning offer and rate IDs that can be booked later.
public isolated class LogisticsCoordinatorAgent {
    *ai:FixedTypedAgent;

    private final ai:Agent agent;

    # Initializes the agent
    # + model - The AI model provider to use
    # + memory - The memory implementation to use
    public function init(ai:ModelProvider model, ai:Memory? memory = ()) returns error? {
        self.agent = check new (
            systemPrompt = {
                role: string `Logistics Coordinator`,
                instructions: string `You find flights and a hotel for a business trip.
Flights: use findAirportCodes if you are unsure of an IATA code, then searchFlights for a round trip in the cabin
you were asked for. Hotels: use lookupLocation for coordinates (of the meeting address if given, otherwise the
city), then searchHotels for the stay dates, then getHotelRates for the two or three most suitable hotels.
Reply with a compact list of the best options. For every option give the exact offerId or rateId, the price
and currency, and whether it is refundable; for flights also the cabin and legs. Never invent an ID or a price.
If a search fails or returns nothing, say so plainly. Hotels marked isTestInventory come from Duffel's test mode,
which only has test properties at one fixed location: offer them as test stand-ins for hotels at the destination,
say that they are test inventory, and do not reject them for their address.`
            },
            model = model,
            memory = memory,
            tools = [self.findAirportCodes, self.searchFlights, self.lookupLocation, self.searchHotels, self.getHotelRates],
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

    # Finds airport and city IATA codes matching a name.
    # + query - A city or airport name, e.g. "Tokyo" or "Heathrow"
    # + return - Matching airports and cities with their IATA codes
    @ai:AgentTool
    isolated function findAirportCodes(string query) returns AirportOption[]|error => findAirports(query);

    # Searches flights for one adult and returns the cheapest offers. Each offer has an offerId that must be quoted exactly when it is used later.
    # + origin - Origin IATA airport or city code, e.g. "LHR" or "LON"
    # + destination - Destination IATA airport or city code
    # + departureDate - Outbound date (YYYY-MM-DD)
    # + cabinClass - Cabin to search
    # + returnDate - Return date (YYYY-MM-DD); omit for a one-way trip
    # + return - Up to five offers, cheapest first
    @ai:AgentTool
    isolated function searchFlights(string origin, string destination, string departureDate, CabinClass cabinClass,
            string? returnDate = ()) returns FlightOffer[]|error =>
        searchFlightOffers(origin, destination, departureDate, returnDate, cabinClass);

    # Finds a city or address and returns its coordinates.
    # + placeName - A city, district or address
    # + return - The best match with latitude and longitude
    @ai:AgentTool
    isolated function lookupLocation(string placeName) returns destination_researcher:GeoLocation|error =>
        destination_researcher:geocode(placeName);

    # Searches hotels near a point for one adult in one room. Returns hotels with their cheapest price; use getHotelRates on a hotel's searchResultId to get bookable rates.
    # + latitude - Latitude to search around
    # + longitude - Longitude to search around
    # + checkInDate - Check-in date (YYYY-MM-DD)
    # + checkOutDate - Check-out date (YYYY-MM-DD)
    # + radiusKm - Search radius in kilometres
    # + return - Up to eight hotels, cheapest first
    @ai:AgentTool
    isolated function searchHotels(decimal latitude, decimal longitude, string checkInDate, string checkOutDate,
            int radiusKm = 5) returns HotelOption[]|error =>
        searchHotelOptions(latitude, longitude, checkInDate, checkOutDate, radiusKm);

    # Returns bookable room rates for a hotel from a hotel search. Each rate has a rateId that must be quoted exactly when it is used later.
    # + searchResultId - The searchResultId of a hotel returned by searchHotels
    # + return - Up to six rates, cheapest first
    @ai:AgentTool
    isolated function getHotelRates(string searchResultId) returns HotelRate[]|error =>
        fetchHotelRates(searchResultId);
}
