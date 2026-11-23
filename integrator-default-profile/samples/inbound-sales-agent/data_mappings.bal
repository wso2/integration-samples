import ballerina/time;

# Escapes single quotes in a value used inside a SOQL string literal.
# + value - the raw value to escape
# + return - the value safe to embed inside a SOQL '...' literal
isolated function escapeSoqlLiteral(string value) returns string {
    string:RegExp quote = re `'`;
    return quote.replaceAll(value, "\\'");
}

# + return - today's date formatted as YYYY-MM-DD
isolated function getTodayDateString() returns string {
    time:Utc now = time:utcNow();
    time:Civil civil = time:utcToCivil(now);
    return formatCivilDate(civil);
}

# + return - the next business day (Mon-Fri) formatted as YYYY-MM-DD
isolated function getNextBusinessDayDateString() returns string {
    time:Utc now = time:utcNow();
    time:Utc nextDay = time:utcAddSeconds(now, 86400);
    time:Civil civil = time:utcToCivil(nextDay);
    int dayOfWeek = getDayOfWeek(nextDay);
    if dayOfWeek == 6 {
        nextDay = time:utcAddSeconds(nextDay, 86400 * 2);
        civil = time:utcToCivil(nextDay);
    } else if dayOfWeek == 0 {
        nextDay = time:utcAddSeconds(nextDay, 86400);
        civil = time:utcToCivil(nextDay);
    }
    return formatCivilDate(civil);
}

# + utc - the UTC timestamp to determine the day of week for
# + return - the day of week: 0 = Sunday, 6 = Saturday
isolated function getDayOfWeek(time:Utc utc) returns int {
    [int, decimal] [epochSeconds, _] = utc;
    int daysSinceEpoch = epochSeconds / 86400;
    // 1970-01-01 was a Thursday (day index 4)
    int dayIndex = (daysSinceEpoch + 4) % 7;
    if dayIndex < 0 {
        dayIndex += 7;
    }
    return dayIndex;
}

isolated function formatCivilDate(time:Civil civil) returns string {
    string month = civil.month < 10 ? string `0${civil.month}` : civil.month.toString();
    string day = civil.day < 10 ? string `0${civil.day}` : civil.day.toString();
    return string `${civil.year}-${month}-${day}`;
}
