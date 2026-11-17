import ballerina/http;
import ballerina/time;

const MAX_FLIGHT_OPTIONS = 5;
const MAX_HOTEL_OPTIONS = 8;
const MAX_RATE_OPTIONS = 6;
const decimal DUFFEL_TEST_HOTEL_LATITUDE = -24.38;
const decimal DUFFEL_TEST_HOTEL_LONGITUDE = -128.32;

// Offers and rates the agent has shown. Swap for a shared store before running more than one replica.
isolated map<FlightOffer> flightOfferCache = {};
isolated map<HotelRate> hotelRateCache = {};

// ---- Places ----

# Finds airport and city IATA codes matching a name.
# + query - A city or airport name
# + return - Matching airports and cities
public isolated function findAirports(string query) returns AirportOption[]|error {
    DuffelPlacesResponse response = check duffelSearchClient->/places/suggestions(headers = duffelHeaders,
        name = query);
    AirportOption[] options = [];
    foreach DuffelPlace place in response.data {
        string? code = place.iata_code;
        if code is string {
            options.push({iataCode: code, placeName: place.name, placeType: place.'type, cityName: place?.city_name});
        }
    }
    return options;
}

// ---- Flights ----

# Searches flights for one adult and returns the cheapest offers, remembering them for later lookup.
# + origin - Origin IATA airport or city code
# + destination - Destination IATA airport or city code
# + departureDate - Outbound date (YYYY-MM-DD)
# + returnDate - Return date (YYYY-MM-DD), or nil for one way
# + cabinClass - Cabin to search
# + return - Up to five offers, cheapest first
public isolated function searchFlightOffers(string origin, string destination, string departureDate,
        string? returnDate, CabinClass cabinClass) returns FlightOffer[]|error {
    SliceRequest[] slices = [{origin, destination, departure_date: departureDate}];
    if returnDate is string {
        slices.push({origin: destination, destination: origin, departure_date: returnDate});
    }
    OfferRequestBody body = {
        data: {slices, passengers: [{'type: "adult"}], cabin_class: cabinClass, max_connections: 1}
    };
    OfferRequestResponse response = check duffelSearchClient->/air/offer_requests.post(message = body,
        headers = duffelHeaders, return_offers = true, supplier_timeout = 20000);
    DuffelOfferRequest offerRequest = response.data;
    if offerRequest.passengers.length() == 0 {
        return error("Duffel returned no passenger IDs for the offer request");
    }
    string passengerId = offerRequest.passengers[0].id;
    FlightOffer[] offers = [];
    foreach DuffelOffer offer in offerRequest.offers {
        offers.push(check toFlightOffer(offer = offer, passengerId = passengerId, requestedCabin = cabinClass));
    }
    FlightOffer[] cheapest = from FlightOffer offer in offers
        order by offer.totalAmount ascending
        limit MAX_FLIGHT_OPTIONS
        select offer;
    foreach FlightOffer offer in cheapest {
        lock {
            flightOfferCache[offer.offerId] = offer.clone();
        }
    }
    return cheapest;
}

# Looks up a flight offer that a search returned.
# + offerId - The offer ID
# + return - The offer, or an error if no search returned it
public isolated function findFlightOffer(string offerId) returns FlightOffer|error {
    lock {
        FlightOffer? offer = flightOfferCache[offerId];
        if offer is () {
            return error(string `Unknown flight offer '${offerId}'. Use an offerId returned by a flight search.`);
        }
        return offer.clone();
    }
}

# Fetches the latest price of an offer. Duffel may return a changed price, or an error if the offer
# has expired or sold out.
# + offerId - The offer ID
# + return - The current fare
public isolated function currentFare(string offerId) returns CurrentFare|error {
    OfferResponse response = check duffelSearchClient->/air/offers/[offerId](headers = duffelHeaders);
    DuffelOffer offer = response.data;
    return {amount: check decimal:fromString(offer.total_amount), exactAmount: offer.total_amount,
        currency: offer.total_currency};
}

# Books a flight offer and pays from the Duffel balance. Never retried automatically.
# + offerId - The offer to book
# + passengerId - The passenger ID from the offer
# + traveler - The traveler's details
# + fare - The current fare from `currentFare`; Duffel requires the exact amount
# + return - The order ID and airline booking reference
public isolated function createFlightOrder(string offerId, string passengerId, PassengerDetails traveler,
        CurrentFare fare) returns FlightOrder|error {
    OrderBody body = {
        data: {
            'type: "instant",
            selected_offers: [offerId],
            passengers: [toOrderPassenger(passengerId, traveler)],
            payments: [{'type: "balance", currency: fare.currency, amount: fare.exactAmount}]
        }
    };
    OrderResponse response = check duffelBookingClient->/air/orders.post(message = body, headers = duffelHeaders);
    return {orderId: response.data.id, bookingReference: response.data.booking_reference};
}

// ---- Stays ----

# Searches hotels near a point for one adult in one room.
# + latitude - Latitude to search around
# + longitude - Longitude to search around
# + checkInDate - Check-in date (YYYY-MM-DD)
# + checkOutDate - Check-out date (YYYY-MM-DD)
# + radiusKm - Search radius in kilometres
# + return - Up to eight hotels, cheapest first
public isolated function searchHotelOptions(decimal latitude, decimal longitude, string checkInDate,
        string checkOutDate, int radiusKm) returns HotelOption[]|error {
    Coordinates coordinates = useDuffelTestHotels
        ? {latitude: DUFFEL_TEST_HOTEL_LATITUDE, longitude: DUFFEL_TEST_HOTEL_LONGITUDE}
        : {latitude, longitude};
    StaysSearchBody body = {
        data: {
            rooms: 1,
            location: {radius: radiusKm, geographic_coordinates: coordinates},
            check_in_date: checkInDate,
            check_out_date: checkOutDate,
            guests: [{'type: "adult"}]
        }
    };
    StaysSearchResponse response = check duffelSearchClient->/stays/search.post(message = body,
        headers = duffelHeaders);
    HotelOption[] options = [];
    foreach StaysSearchResult result in response.data.results {
        string? amount = result?.cheapest_rate_total_amount;
        string? currency = result?.cheapest_rate_currency;
        if amount is string && currency is string {
            options.push(check toHotelOption(result, amount, currency));
        }
    }
    return from HotelOption option in options
        order by option.cheapestTotal ascending
        limit MAX_HOTEL_OPTIONS
        select option;
}

# Returns bookable rates for a hotel from a search, remembering them for later lookup.
# + searchResultId - The hotel's search result ID
# + return - Up to six rates, cheapest first
public isolated function fetchHotelRates(string searchResultId) returns HotelRate[]|error {
    StaysRatesResponse response = check duffelSearchClient->/stays/search_results/[searchResultId]/actions/fetch_all_rates
        .post(message = (), headers = duffelHeaders);
    StaysSearchResult result = response.data;
    int nights = check daysBetween(result.check_in_date, result.check_out_date);
    StaysRoom[] rooms = result.accommodation?.rooms ?: [];
    HotelRate[] rates = [];
    foreach StaysRoom room in rooms {
        foreach StaysRate rate in room.rates {
            rates.push(check toHotelRate(result, room, rate, nights));
        }
    }
    HotelRate[] cheapest = from HotelRate rate in rates
        order by rate.totalAmount ascending
        limit MAX_RATE_OPTIONS
        select rate;
    foreach HotelRate rate in cheapest {
        lock {
            hotelRateCache[rate.rateId] = rate.clone();
        }
    }
    return cheapest;
}

# Looks up a hotel rate that getHotelRates returned.
# + rateId - The rate ID
# + return - The rate, or an error if it was never returned
public isolated function findHotelRate(string rateId) returns HotelRate|error {
    lock {
        HotelRate? rate = hotelRateCache[rateId];
        if rate is () {
            return error(string `Unknown hotel rate '${rateId}'. Use a rateId returned by getHotelRates.`);
        }
        return rate.clone();
    }
}

# Creates a quote for a rate, which confirms availability and the current price. Never retried automatically.
# + rateId - The rate to quote
# + return - The quote
public isolated function createHotelQuote(string rateId) returns HotelQuote|error {
    QuoteBody body = {data: {rate_id: rateId}};
    QuoteResponse response = check duffelBookingClient->/stays/quotes.post(message = body, headers = duffelHeaders);
    StaysQuote quote = response.data;
    return {quoteId: quote.id, amount: check decimal:fromString(quote.total_amount), currency: quote.total_currency};
}

# Books a quoted hotel rate, paid from the Duffel balance. Never retried automatically.
# + quoteId - The quote to book
# + guest - The lead guest's details
# + return - The booking ID, hotel reference (which Duffel may leave empty) and status
public isolated function createHotelBooking(string quoteId, PassengerDetails guest) returns HotelBooking|error {
    StaysBookingBody body = {
        data: {
            quote_id: quoteId,
            guests: [{given_name: guest.givenName, family_name: guest.familyName}],
            email: guest.email,
            phone_number: guest.phoneNumber
        }
    };
    StaysBookingResponse response = check duffelBookingClient->/stays/bookings.post(message = body,
        headers = duffelHeaders);
    StaysBooking booking = response.data;
    return {bookingId: booking.id, reference: booking.reference, status: booking.status};
}

# A short, log-safe description of a failed Duffel call, including Duffel's error body.
# + err - The error
# + return - The description
public isolated function describeError(error err) returns string {
    string message = err.message();
    if err is http:ApplicationResponseError {
        string bodyText = err.detail().body.toString();
        message = string `${message} (HTTP ${err.detail().statusCode}): ${bodyText.length() > 500
            ? bodyText.substring(0, 500) : bodyText}`;
    }
    return message;
}

isolated function daysBetween(string fromDate, string toDate) returns int|error {
    time:Utc fromUtc = check time:utcFromString(fromDate.substring(0, 10) + "T00:00:00Z");
    time:Utc toUtc = check time:utcFromString(toDate.substring(0, 10) + "T00:00:00Z");
    return <int>(time:utcDiffSeconds(toUtc, fromUtc) / 86400d);
}
