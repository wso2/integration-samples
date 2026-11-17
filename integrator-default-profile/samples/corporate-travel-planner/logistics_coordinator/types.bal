public type CabinClass "economy"|"premium_economy"|"business"|"first";

public type AirportOption record {|
    string iataCode;
    string placeName;
    string placeType;
    string? cityName;
|};

# A flight offer the agent has seen. Only offers returned by a search can be looked up later,
# so an LLM cannot invent an offer ID.
public type FlightOffer record {|
    string offerId;
    string passengerId;
    string airline;
    CabinClass cabinClass;
    decimal totalAmount;
    string currency;
    decimal longestLegHours;
    string departureDate;
    string[] legs;
    boolean refundable;
    boolean changeable;
    string expiresAt;
|};

public type HotelOption record {|
    string searchResultId;
    string hotelName;
    int? starRating;
    string? address;
    decimal cheapestTotal;
    string currency;
    # True in Duffel test mode: the hotel is a test property standing in for one at the destination
    boolean isTestInventory;
|};

# A bookable hotel rate the agent has seen. Only rates returned by getHotelRates can be looked up later.
public type HotelRate record {|
    string rateId;
    string hotelName;
    string roomName;
    string boardType;
    decimal totalAmount;
    string currency;
    string checkInDate;
    string checkOutDate;
    int nights;
    boolean refundable;
    # True in Duffel test mode: the rate is for a test property standing in for one at the destination
    boolean isTestInventory;
|};

# The traveler details a booking needs.
public type PassengerDetails record {|
    string givenName;
    string familyName;
    # One of mr, ms, mrs, miss, dr
    string title;
    # m or f
    string gender;
    string bornOn;
    string email;
    # E.164, e.g. +441632960001
    string phoneNumber;
|};

# The latest price of an offer. `exactAmount` is Duffel's string, which an order must repeat exactly.
public type CurrentFare record {|
    decimal amount;
    string exactAmount;
    string currency;
|};

public type FlightOrder record {|
    string orderId;
    string bookingReference;
|};

public type HotelQuote record {|
    string quoteId;
    decimal amount;
    string currency;
|};

public type HotelBooking record {|
    string bookingId;
    string? reference;
    string status;
|};

// ---- Duffel wire types (field names match Duffel's JSON) ----

type DuffelPlace record {
    string 'type;
    string? iata_code;
    string name;
    string? city_name?;
};

type DuffelPlacesResponse record {
    DuffelPlace[] data;
};

type SliceRequest record {|
    string origin;
    string destination;
    string departure_date;
|};

type PassengerRequest record {|
    string 'type;
|};

type OfferRequestData record {|
    SliceRequest[] slices;
    PassengerRequest[] passengers;
    CabinClass cabin_class;
    int max_connections;
|};

type OfferRequestBody record {|
    OfferRequestData data;
|};

type DuffelAirport record {
    string? iata_code;
};

type DuffelCarrier record {
    string? iata_code?;
    string name;
};

type SegmentPassenger record {
    string? cabin_class?;
};

type DuffelSegment record {
    string departing_at;
    string arriving_at;
    DuffelAirport origin;
    DuffelAirport destination;
    DuffelCarrier marketing_carrier;
    string marketing_carrier_flight_number;
    SegmentPassenger[] passengers?;
};

type DuffelSlice record {
    string? duration?;
    DuffelSegment[] segments;
};

type DuffelPenalty record {
    boolean allowed;
};

type DuffelConditions record {
    DuffelPenalty? refund_before_departure?;
    DuffelPenalty? change_before_departure?;
};

type DuffelOffer record {
    string id;
    string total_amount;
    string total_currency;
    string expires_at;
    DuffelCarrier owner;
    DuffelSlice[] slices;
    DuffelConditions? conditions?;
};

type DuffelPassenger record {
    string id;
};

type DuffelOfferRequest record {
    string id;
    DuffelPassenger[] passengers;
    DuffelOffer[] offers;
};

type OfferRequestResponse record {
    DuffelOfferRequest data;
};

type OfferResponse record {
    DuffelOffer data;
};

type OrderPassenger record {|
    string id;
    string given_name;
    string family_name;
    string title;
    string gender;
    string born_on;
    string email;
    string phone_number;
|};

type OrderPayment record {|
    string 'type;
    string currency;
    string amount;
|};

type OrderData record {|
    string 'type;
    string[] selected_offers;
    OrderPassenger[] passengers;
    OrderPayment[] payments;
|};

type OrderBody record {|
    OrderData data;
|};

type DuffelOrder record {
    string id;
    string booking_reference;
};

type OrderResponse record {
    DuffelOrder data;
};

type Coordinates record {|
    decimal latitude;
    decimal longitude;
|};

type StaysLocation record {|
    int radius;
    Coordinates geographic_coordinates;
|};

type StaysSearchData record {|
    int rooms;
    StaysLocation location;
    string check_in_date;
    string check_out_date;
    PassengerRequest[] guests;
|};

type StaysSearchBody record {|
    StaysSearchData data;
|};

type StaysAddress record {
    string? line_one?;
    string? city_name?;
};

type StaysAccommodationLocation record {
    StaysAddress? address?;
};

type CancellationStep record {
    string refund_amount;
    string before;
};

type StaysRate record {
    string id;
    string total_amount;
    string total_currency;
    string? board_type?;
    CancellationStep[]? cancellation_timeline?;
};

type StaysRoom record {
    string name;
    StaysRate[] rates;
};

type StaysAccommodation record {
    string id;
    string name;
    int? rating?;
    StaysAccommodationLocation? location?;
    StaysRoom[]? rooms?;
};

type StaysSearchResult record {
    string id;
    string check_in_date;
    string check_out_date;
    string? cheapest_rate_total_amount?;
    string? cheapest_rate_currency?;
    StaysAccommodation accommodation;
};

type StaysSearchResults record {
    StaysSearchResult[] results;
};

type StaysSearchResponse record {
    StaysSearchResults data;
};

type StaysRatesResponse record {
    StaysSearchResult data;
};

type QuoteBody record {|
    record {|string rate_id;|} data;
|};

type StaysQuote record {
    string id;
    string total_amount;
    string total_currency;
};

type QuoteResponse record {
    StaysQuote data;
};

type BookingGuest record {|
    string given_name;
    string family_name;
|};

type StaysBookingData record {|
    string quote_id;
    BookingGuest[] guests;
    string email;
    string phone_number;
|};

type StaysBookingBody record {|
    StaysBookingData data;
|};

type StaysBooking record {
    string id;
    string? reference;
    string status;
};

type StaysBookingResponse record {
    StaysBooking data;
};
