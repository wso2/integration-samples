isolated function toFlightOffer(DuffelOffer offer, string passengerId, CabinClass requestedCabin)
        returns FlightOffer|error {
    string[] legs = [];
    decimal longestLeg = 0;
    string departureDate = "";
    CabinClass cabinClass = requestedCabin;
    foreach DuffelSlice slice in offer.slices {
        DuffelSegment[] segments = slice.segments;
        if segments.length() == 0 {
            continue;
        }
        DuffelSegment first = segments[0];
        DuffelSegment last = segments[segments.length() - 1];
        string? duration = slice?.duration;
        decimal hours = duration is string ? durationHours(duration).round(1) : 0;
        if hours > longestLeg {
            longestLeg = hours;
        }
        if departureDate == "" {
            departureDate = first.departing_at.substring(0, 10);
            CabinClass? segmentCabin = segmentCabinClass(first);
            if segmentCabin is CabinClass {
                cabinClass = segmentCabin;
            }
        }
        string flightNumbers = string:'join(", ", ...from DuffelSegment segment in segments
            select string `${segment.marketing_carrier?.iata_code ?: ""}${segment.marketing_carrier_flight_number}`);
        legs.push(string `${first.origin.iata_code ?: "?"} ${first.departing_at} -> ${last.destination.iata_code ?: "?"} ` +
            string `${last.arriving_at} (${hours}h, ${segments.length() - 1} stop(s), ${flightNumbers})`);
    }
    DuffelConditions? conditions = offer?.conditions;
    return {
        offerId: offer.id,
        passengerId,
        airline: offer.owner.name,
        cabinClass,
        totalAmount: check decimal:fromString(offer.total_amount),
        currency: offer.total_currency,
        longestLegHours: longestLeg,
        departureDate,
        legs,
        refundable: isAllowed(conditions is () ? () : conditions?.refund_before_departure),
        changeable: isAllowed(conditions is () ? () : conditions?.change_before_departure),
        expiresAt: offer.expires_at
    };
}

isolated function segmentCabinClass(DuffelSegment segment) returns CabinClass? {
    SegmentPassenger[] passengers = segment.passengers ?: [];
    if passengers.length() == 0 {
        return ();
    }
    string? cabin = passengers[0]?.cabin_class;
    return cabin is CabinClass ? cabin : ();
}

isolated function isAllowed(DuffelPenalty? penalty) returns boolean => penalty is DuffelPenalty && penalty.allowed;

isolated function toHotelOption(StaysSearchResult result, string amount, string currency) returns HotelOption|error {
    StaysAccommodation accommodation = result.accommodation;
    return {
        searchResultId: result.id,
        hotelName: accommodation.name,
        starRating: accommodation?.rating,
        address: formatAddress(accommodation?.location),
        cheapestTotal: check decimal:fromString(amount),
        currency,
        isTestInventory: useDuffelTestHotels
    };
}

isolated function formatAddress(StaysAccommodationLocation? location) returns string? {
    StaysAddress? address = location is () ? () : location?.address;
    if address is () {
        return ();
    }
    string[] lines = from string? line in [address?.line_one, address?.city_name]
        where line is string
        select line;
    return lines.length() == 0 ? () : string:'join(", ", ...lines);
}

isolated function toHotelRate(StaysSearchResult result, StaysRoom room, StaysRate rate, int nights)
        returns HotelRate|error => {
    rateId: rate.id,
    hotelName: result.accommodation.name,
    roomName: room.name,
    boardType: rate?.board_type ?: "unknown",
    totalAmount: check decimal:fromString(rate.total_amount),
    currency: rate.total_currency,
    checkInDate: result.check_in_date,
    checkOutDate: result.check_out_date,
    nights,
    refundable: hasRefund(rate?.cancellation_timeline),
    isTestInventory: useDuffelTestHotels
};

isolated function hasRefund(CancellationStep[]? timeline) returns boolean {
    if timeline is () {
        return false;
    }
    foreach CancellationStep step in timeline {
        decimal|error refund = decimal:fromString(step.refund_amount);
        if refund is decimal && refund > 0d {
            return true;
        }
    }
    return false;
}

isolated function toOrderPassenger(string passengerId, PassengerDetails traveler) returns OrderPassenger => {
    id: passengerId,
    given_name: traveler.givenName,
    family_name: traveler.familyName,
    title: traveler.title,
    gender: traveler.gender,
    born_on: traveler.bornOn,
    email: traveler.email,
    phone_number: traveler.phoneNumber
};

# Hours in an ISO 8601 duration such as `PT7H45M` or `P1DT2H10M`.
isolated function durationHours(string duration) returns decimal {
    decimal hours = 0;
    string digits = "";
    boolean inTime = false;
    foreach string char in duration {
        if char == "T" {
            inTime = true;
        } else if char >= "0" && char <= "9" {
            digits += char;
        } else {
            int|error parsed = int:fromString(digits);
            int amount = parsed is int ? parsed : 0;
            if char == "D" {
                hours += <decimal>(amount * 24);
            } else if char == "H" {
                hours += <decimal>amount;
            } else if char == "M" && inTime {
                hours += <decimal>amount / 60d;
            }
            digits = "";
        }
    }
    return hours;
}
