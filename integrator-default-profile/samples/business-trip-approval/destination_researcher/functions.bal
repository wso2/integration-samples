import ballerina/time;

// Open-Meteo forecasts up to 16 days ahead; beyond that, past weather on the same dates is used.
const FORECAST_WINDOW_DAYS = 15;
// The historical archive is a few days behind today.
const ARCHIVE_DELAY_DAYS = 6;
const MAX_YEARS_BACK = 3;
const DAILY_FIELDS = "temperature_2m_max,temperature_2m_min,precipitation_sum";

# Finds a city or place and returns its coordinates, country and time zone (Open-Meteo geocoding).
# + placeName - A city or place name, e.g. "Kyoto"
# + countryName - The country, to pick the right place when the name is used in several countries
# + return - The best match
public isolated function geocode(string placeName, string? countryName = ()) returns GeoLocation|error {
    GeocodingResponse response = check geocodingClient->/search(name = placeName, count = 10, language = "en");
    GeocodingMatch[] matches = response.results ?: [];
    if matches.length() == 0 {
        return error(string `No location found for '${placeName}'`);
    }
    if countryName is string {
        string wanted = countryName.trim().toLowerAscii();
        foreach GeocodingMatch candidate in matches {
            if (candidate?.country ?: "").toLowerAscii() == wanted {
                return toGeoLocation(candidate);
            }
        }
    }
    return toGeoLocation(matches[0]);
}

# Daily weather for the given dates: a forecast within about two weeks, otherwise the same dates in the most
# recent year the historical archive covers.
# + latitude - Latitude of the place
# + longitude - Longitude of the place
# + startDate - First day (YYYY-MM-DD)
# + endDate - Last day (YYYY-MM-DD)
# + return - The daily outlook
public isolated function weatherOutlook(decimal latitude, decimal longitude, string startDate, string endDate)
        returns WeatherOutlook|error {
    int daysAhead = check daysBetween(todayIso(), startDate);
    if daysAhead < 0 {
        return error("The start date is in the past");
    }
    int tripDays = check daysBetween(startDate, endDate);
    if tripDays < 0 || tripDays > 30 {
        return error("The end date must be on or after the start date, and within 30 days of it");
    }
    if daysAhead + tripDays <= FORECAST_WINDOW_DAYS {
        WeatherResponse forecast = check forecastClient->/forecast(latitude = latitude, longitude = longitude,
            daily = DAILY_FIELDS, timezone = "auto", start_date = startDate, end_date = endDate);
        return toOutlook(response = forecast, basis = "forecast");
    }
    // Step back whole years until the dates are in the archive, which a trip over a year away needs.
    foreach int yearsBack in 1 ... MAX_YEARS_BACK {
        string pastEnd = check shiftYear(isoDate = endDate, years = -yearsBack);
        if check daysBetween(pastEnd, todayIso()) < ARCHIVE_DELAY_DAYS {
            continue;
        }
        string pastStart = check shiftYear(isoDate = startDate, years = -yearsBack);
        WeatherResponse history = check archiveClient->/archive(latitude = latitude, longitude = longitude,
            daily = DAILY_FIELDS, timezone = "auto", start_date = pastStart, end_date = pastEnd);
        string basis = yearsBack == 1 ? "same dates last year" : string `same dates ${yearsBack} years ago`;
        // shiftYear moves 29 February to 28 February in a year without it; say so.
        if isLeapDay(startDate) || isLeapDay(endDate) {
            basis += ", with 28 February standing in for 29 February";
        }
        return toOutlook(response = history, basis = basis);
    }
    return error(string `No weather outlook is available: the dates are beyond the forecast, and the archive does ` +
        string `not have them yet in any of the last ${MAX_YEARS_BACK} years`);
}

# Public holidays at the destination between two dates, inclusive (Nager.Date).
# + countryCode - ISO 3166-1 alpha-2 country code, e.g. "JP"
# + startDate - First day (YYYY-MM-DD)
# + endDate - Last day (YYYY-MM-DD)
# + return - The holidays in date order, national and regional
public isolated function publicHolidays(string countryCode, string startDate, string endDate)
        returns PublicHoliday[]|error {
    string code = countryCode.trim().toUpperAscii();
    if !re `[A-Z]{2}`.isFullMatch(code) {
        return error(string `Invalid country code '${countryCode}', expected two letters such as JP`);
    }
    int tripDays = check daysBetween(startDate, endDate);
    if tripDays < 0 {
        return error("The end date must be on or after the start date");
    }
    int firstYear = check int:fromString(startDate.substring(0, 4));
    int lastYear = check int:fromString(endDate.substring(0, 4));
    PublicHoliday[] holidays = [];
    foreach int year in firstYear ... lastYear {
        NagerHoliday[] yearHolidays = check holidaysClient->/PublicHolidays/[year]/[code];
        foreach NagerHoliday holiday in yearHolidays {
            if holiday.date >= startDate && holiday.date <= endDate {
                holidays.push(toHoliday(holiday));
            }
        }
    }
    return holidays;
}

// ---- Dates ----

isolated function todayIso() returns string => time:utcToString(time:utcNow()).substring(0, 10);

isolated function toUtcDate(string isoDate) returns time:Utc|error {
    if !re `[0-9]{4}-[0-9]{2}-[0-9]{2}`.isFullMatch(isoDate) {
        return error(string `Invalid date '${isoDate}', expected YYYY-MM-DD`);
    }
    string[] parts = re `-`.split(isoDate);
    int year = check int:fromString(parts[0]);
    int month = check int:fromString(parts[1]);
    int day = check int:fromString(parts[2]);
    time:Civil civil = {year, month, day, hour: 0, minute: 0, second: 0, utcOffset: {hours: 0, minutes: 0}};
    return time:utcFromCivil(civil);
}

isolated function daysBetween(string fromDate, string toDate) returns int|error {
    time:Utc fromUtc = check toUtcDate(fromDate);
    time:Utc toUtc = check toUtcDate(toDate);
    return <int>(time:utcDiffSeconds(toUtc, fromUtc) / 86400d);
}

isolated function isLeapDay(string isoDate) returns boolean => isoDate.substring(4) == "-02-29";

isolated function shiftYear(string isoDate, int years) returns string|error {
    time:Civil civil = time:utcToCivil(check toUtcDate(isoDate));
    int day = civil.month == 2 && civil.day == 29 ? 28 : civil.day;
    int year = civil.year + years;
    string monthText = civil.month < 10 ? string `0${civil.month}` : civil.month.toString();
    string dayText = day < 10 ? string `0${day}` : day.toString();
    return string `${year}-${monthText}-${dayText}`;
}
