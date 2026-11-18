import ballerina/time;
import wso2/destination_researcher;
import wso2/logistics_coordinator;

// Stand-in for the company's travel-policy service, keyed by employee grade.
final readonly & map<TravelPolicy> travelPolicies = {
    "staff": {
        grade: "staff",
        defaultCabin: "economy",
        longHaulCabin: "premium_economy",
        upgradeAfterHours: 8,
        hotelNightlyCapUsd: 250,
        tripCapUsd: 3500,
        minAdvanceDays: 7
    },
    "director": {
        grade: "director",
        defaultCabin: "premium_economy",
        longHaulCabin: "business",
        upgradeAfterHours: 6,
        hotelNightlyCapUsd: 400,
        tripCapUsd: 9000,
        minAdvanceDays: 3
    }
};

# Returns the travel policy for an employee grade.
# + grade - The employee grade, e.g. "staff"
# + return - The policy
public isolated function getPolicy(string grade) returns TravelPolicy|error {
    TravelPolicy? policy = travelPolicies[grade];
    if policy is () {
        return error(string `No travel policy for grade '${grade}'`);
    }
    return policy;
}

# Checks a flight and/or hotel rate against the policy for a grade. Deterministic: the LLM can explain
# the result but never decides it. Totals are converted to USD at the latest ECB rate.
# + grade - The traveler's grade
# + flight - The chosen flight offer, if any
# + hotel - The chosen hotel rate, if any
# + adviceLevel - FCDO advice for the destination, or nil if it could not be checked
# + return - Whether the trip complies, with violations and warnings
public isolated function evaluateTrip(string grade, logistics_coordinator:FlightOffer? flight,
        logistics_coordinator:HotelRate? hotel, destination_researcher:AdviceLevel? adviceLevel)
        returns PolicyEvaluation|error {
    TravelPolicy policy = check getPolicy(grade);
    string[] violations = [];
    string[] warnings = [];
    decimal totalUsd = 0;
    logistics_coordinator:CabinClass highestAllowedCabin = policy.defaultCabin;

    if flight is logistics_coordinator:FlightOffer {
        highestAllowedCabin = flight.longestLegHours >= policy.upgradeAfterHours
            ? policy.longHaulCabin : policy.defaultCabin;
        int flownRank = logistics_coordinator:cabinRank(flight.cabinClass);
        if flownRank > logistics_coordinator:cabinRank(highestAllowedCabin) {
            violations.push(string `Cabin '${flight.cabinClass}' exceeds the highest allowed '${highestAllowedCabin}' ` +
                string `for a ${flight.longestLegHours}h longest leg`);
        }
        totalUsd += check toUsd(amount = flight.totalAmount, currency = flight.currency);
        int advanceDays = check daysFromToday(flight.departureDate);
        if advanceDays < policy.minAdvanceDays {
            warnings.push(string `Booked ${advanceDays} day(s) ahead; policy asks for ${policy.minAdvanceDays}`);
        }
        if !flight.refundable {
            warnings.push("The fare is non-refundable");
        }
    }

    if hotel is logistics_coordinator:HotelRate {
        decimal hotelUsd = check toUsd(amount = hotel.totalAmount, currency = hotel.currency);
        totalUsd += hotelUsd;
        decimal nightlyUsd = hotel.nights > 0 ? hotelUsd / <decimal>hotel.nights : hotelUsd;
        if nightlyUsd > policy.hotelNightlyCapUsd {
            violations.push(string `Hotel costs USD ${nightlyUsd.round(2)}/night; the cap is USD ${policy.hotelNightlyCapUsd}`);
        }
        if !hotel.refundable {
            warnings.push("The hotel rate is non-refundable");
        }
    }

    if totalUsd > policy.tripCapUsd {
        violations.push(string `Trip total USD ${totalUsd.round(2)} exceeds the USD ${policy.tripCapUsd} trip cap`);
    }

    if adviceLevel is () {
        warnings.push("FCDO travel advice could not be checked");
    } else if adviceLevel == "AVOID_ALL_TRAVEL" || adviceLevel == "ESSENTIAL_TRAVEL_ONLY" {
        violations.push(string `FCDO advice for the destination is ${adviceLevel}`);
    } else if adviceLevel == "AVOID_PARTS" {
        warnings.push("FCDO advises against travel to parts of the destination country");
    }

    return {compliant: violations.length() == 0, totalUsd: totalUsd.round(2), highestAllowedCabin, violations,
        warnings};
}

# The FCDO advice level for a country, or nil if it could not be fetched.
# + countryName - Country name in English
# + return - The advice level
public isolated function adviceLevelFor(string countryName) returns destination_researcher:AdviceLevel? {
    destination_researcher:TravelAdvisory|error advisory = destination_researcher:travelAdvisory(countryName);
    return advisory is destination_researcher:TravelAdvisory ? advisory.adviceLevel : ();
}

# Converts an amount between currencies at the latest ECB reference rate.
# + amount - The amount
# + fromCurrency - ISO 4217 code of the amount
# + toCurrency - ISO 4217 code to convert to
# + return - The converted amount and the rate used
public isolated function convertCurrency(decimal amount, string fromCurrency, string toCurrency)
        returns CurrencyConversion|error {
    string sourceCode = fromCurrency.toUpperAscii();
    string targetCode = toCurrency.toUpperAscii();
    if sourceCode == targetCode {
        return {amount, fromCurrency: sourceCode, converted: amount, toCurrency: targetCode, rate: 1,
            rateDate: time:utcToString(time:utcNow()).substring(0, 10)};
    }
    FxResponse response = check fxClient->/latest(base = sourceCode, symbols = targetCode);
    decimal? rate = response.rates[targetCode];
    if rate is () {
        return error(string `No exchange rate from ${sourceCode} to ${targetCode}`);
    }
    return {amount, fromCurrency: sourceCode, converted: (amount * rate).round(2), toCurrency: targetCode, rate,
        rateDate: response.date};
}

isolated function toUsd(decimal amount, string currency) returns decimal|error {
    CurrencyConversion conversion = check convertCurrency(amount = amount, fromCurrency = currency, toCurrency = "USD");
    return conversion.converted;
}

isolated function daysFromToday(string isoDate) returns int|error {
    time:Utc target = check time:utcFromString(isoDate.substring(0, 10) + "T00:00:00Z");
    time:Utc today = check time:utcFromString(time:utcToString(time:utcNow()).substring(0, 10) + "T00:00:00Z");
    return <int>(time:utcDiffSeconds(target, today) / 86400d);
}
