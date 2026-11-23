import ballerina/time;
import wso2/destination_researcher;
import wso2/travel_advisor;

const MAX_TRIP_DAYS = 90;

// Stand-in for the company's travel-policy service, keyed by employee grade.
final readonly & map<TravelPolicy> travelPolicies = {
    "staff": {grade: "staff", minNoticeDays: 14, maxTripDaysWithoutEscalation: 10},
    "director": {grade: "director", minNoticeDays: 7, maxTripDaysWithoutEscalation: 21},
    "vp": {grade: "vp", minNoticeDays: 3, maxTripDaysWithoutEscalation: 30}
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

# Looks up the FCDO advice and the public holidays for a trip, then checks it against the policy.
# + grade - The traveler's grade
# + countryName - Destination country name in English, e.g. "Japan"
# + countryCode - Two-letter destination country code, e.g. "JP"
# + startDate - First day of the trip (YYYY-MM-DD)
# + endDate - Last day of the trip (YYYY-MM-DD)
# + justification - Why the trip is essential, when the FCDO advises against non-essential travel
# + return - The policy result
public isolated function checkTrip(string grade, string countryName, string countryCode, string startDate,
        string endDate, string? justification = ()) returns PolicyEvaluation|error {
    travel_advisor:TravelAdvisory|error advisory = travel_advisor:travelAdvisory(countryName);
    destination_researcher:PublicHoliday[]|error holidays = destination_researcher:publicHolidays(countryCode,
        startDate, endDate);
    return evaluateTrip(grade, startDate, endDate, justification,
        advisory is travel_advisor:TravelAdvisory ? advisory.adviceLevel : (),
        holidays is error ? () : holidays);
}

# Checks a trip against the policy for a grade. Deterministic: the agents explain the result but never decide it.
# + grade - The traveler's grade
# + startDate - First day of the trip (YYYY-MM-DD)
# + endDate - Last day of the trip (YYYY-MM-DD)
# + justification - Why the trip is essential, if given
# + adviceLevel - The FCDO advice level, or nil when it could not be checked
# + holidays - Public holidays during the trip, or nil when they could not be checked
# + return - The policy result
public isolated function evaluateTrip(string grade, string startDate, string endDate, string? justification,
        travel_advisor:AdviceLevel? adviceLevel, destination_researcher:PublicHoliday[]? holidays)
        returns PolicyEvaluation|error {
    TravelPolicy policy = check getPolicy(grade);
    int noticeDays = check daysBetween(todayIso(), startDate);
    int tripDays = check daysBetween(startDate, endDate) + 1;
    string[] blockers = [];
    string[] secondApprovalReasons = [];
    string[] warnings = [];

    if noticeDays < 0 {
        blockers.push("The trip starts in the past");
    } else if noticeDays < policy.minNoticeDays {
        warnings.push(string `Requested ${noticeDays} day(s) ahead; the policy asks for ${policy.minNoticeDays}`);
    }
    if tripDays < 1 {
        blockers.push("The end date is before the start date");
    } else if tripDays > MAX_TRIP_DAYS {
        blockers.push(string `The trip is ${tripDays} days long; business trips are limited to ${MAX_TRIP_DAYS} days`);
    } else if tripDays > policy.maxTripDaysWithoutEscalation {
        secondApprovalReasons.push(string `The trip is ${tripDays} days long; trips over ` +
            string `${policy.maxTripDaysWithoutEscalation} days need a second approval`);
    }

    if adviceLevel == "AVOID_ALL_TRAVEL" {
        blockers.push("The FCDO advises against all travel to the destination");
    } else if adviceLevel == "ESSENTIAL_TRAVEL_ONLY" {
        secondApprovalReasons.push("The FCDO advises against all but essential travel to the destination");
        if (justification ?: "").trim() == "" {
            blockers.push("The FCDO advises against all but essential travel, so the request needs a justification");
        }
    } else if adviceLevel == "AVOID_PARTS" {
        warnings.push("The FCDO advises against travel to parts of the destination country; " +
            "check that the trip avoids them");
    } else if adviceLevel is () {
        warnings.push("The FCDO travel advice could not be checked");
    }

    if holidays is () {
        warnings.push("Public holidays at the destination could not be checked");
    } else {
        foreach destination_researcher:PublicHoliday holiday in holidays {
            warnings.push(string `${holiday.date} is ${holiday.name}` +
                (holiday.regional ? string ` in ${string:'join(", ", ...holiday.regions)}` : "") +
                ", a public holiday; offices may be closed");
        }
    }

    return {submittable: blockers.length() == 0, blockers, secondApprovalReasons, warnings, noticeDays, tripDays,
        adviceLevel, publicHolidays: holidays};
}

isolated function todayIso() returns string => time:utcToString(time:utcNow()).substring(0, 10);

isolated function daysBetween(string fromDate, string toDate) returns int|error {
    time:Utc fromUtc = check toUtcDate(fromDate);
    time:Utc toUtc = check toUtcDate(toDate);
    return <int>(time:utcDiffSeconds(toUtc, fromUtc) / 86400d);
}

isolated function toUtcDate(string isoDate) returns time:Utc|error {
    if !re `[0-9]{4}-[0-9]{2}-[0-9]{2}`.isFullMatch(isoDate) {
        return error(string `Invalid date '${isoDate}', expected YYYY-MM-DD`);
    }
    return time:utcFromString(isoDate + "T00:00:00Z");
}
