import ballerina/lang.regexp;
import ballerina/time as time;

public function getCurrentPeriodDates() returns [string, string]|error {
    time:Utc currentUtc = time:utcNow();
    time:Civil currentCivil = time:utcToCivil(currentUtc);

    time:Civil startDate;
    time:Civil endDate;

    if timePeriod == "monthly" {
        int lastMonth = currentCivil.month - 1;
        int year = currentCivil.year;
        if lastMonth < 1 {
            lastMonth = 12;
            year = year - 1;
        }
        startDate = {
            year: year,
            month: lastMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };

        int nextMonth = lastMonth + 1;
        int endYear = year;
        if nextMonth > 12 {
            nextMonth = 1;
            endYear = endYear + 1;
        }
        time:Civil tempDate = {
            year: endYear,
            month: nextMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };
        time:Utc tempUtc = check time:utcFromCivil(tempDate);
        time:Utc endUtc = time:utcAddSeconds(tempUtc, -86400.0);
        endDate = time:utcToCivil(endUtc);
    } else {
        time:Utc startUtc = time:utcAddSeconds(currentUtc, -2592000.0);
        startDate = time:utcToCivil(startUtc);
        endDate = currentCivil;
    }

    string startDateStr = check time:civilToString(startDate);
    string endDateStr = check time:civilToString(endDate);

    regexp:RegExp datePattern = re `^\d{4}-\d{2}-\d{2}`;
    regexp:Span? startMatch = datePattern.find(startDateStr);
    regexp:Span? endMatch = datePattern.find(endDateStr);

    string finalStartDate = startMatch is regexp:Span ? startDateStr.substring(startMatch.startIndex, startMatch.endIndex) : startDateStr;
    string finalEndDate = endMatch is regexp:Span ? endDateStr.substring(endMatch.startIndex, endMatch.endIndex) : endDateStr;

    return [finalStartDate, finalEndDate];
}

public function getPreviousPeriodDates() returns [string, string]|error {
    time:Utc currentUtc = time:utcNow();
    time:Civil currentCivil = time:utcToCivil(currentUtc);

    time:Civil startDate;
    time:Civil endDate;

    if comparisonPeriod == "MoM" {
        int twoMonthsAgo = currentCivil.month - 2;
        int year = currentCivil.year;
        if twoMonthsAgo < 1 {
            twoMonthsAgo = twoMonthsAgo + 12;
            year = year - 1;
        }
        startDate = {
            year: year,
            month: twoMonthsAgo,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };

        int nextMonth = twoMonthsAgo + 1;
        int endYear = year;
        if nextMonth > 12 {
            nextMonth = 1;
            endYear = endYear + 1;
        }
        time:Civil tempDate = {
            year: endYear,
            month: nextMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };
        time:Utc tempUtc = check time:utcFromCivil(tempDate);
        time:Utc endUtc = time:utcAddSeconds(tempUtc, -86400.0);
        endDate = time:utcToCivil(endUtc);
    } else if comparisonPeriod == "YoY" {
        int lastYear = currentCivil.year - 1;
        int lastMonth = currentCivil.month - 1;
        if lastMonth < 1 {
            lastMonth = 12;
            lastYear = lastYear - 1;
        }
        startDate = {
            year: lastYear,
            month: lastMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };

        int nextMonth = lastMonth + 1;
        int endYear = lastYear;
        if nextMonth > 12 {
            nextMonth = 1;
            endYear = endYear + 1;
        }
        time:Civil tempDate = {
            year: endYear,
            month: nextMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };
        time:Utc tempUtc = check time:utcFromCivil(tempDate);
        time:Utc endUtc = time:utcAddSeconds(tempUtc, -86400.0);
        endDate = time:utcToCivil(endUtc);
    } else {
        time:Utc startUtc = time:utcAddSeconds(currentUtc, -5184000.0);
        time:Utc endUtc = time:utcAddSeconds(currentUtc, -2592000.0);
        startDate = time:utcToCivil(startUtc);
        endDate = time:utcToCivil(endUtc);
    }

    string startDateStr = check time:civilToString(startDate);
    string endDateStr = check time:civilToString(endDate);

    regexp:RegExp datePattern = re `^\d{4}-\d{2}-\d{2}`;
    regexp:Span? startMatch = datePattern.find(startDateStr);
    regexp:Span? endMatch = datePattern.find(endDateStr);

    string finalStartDate = startMatch is regexp:Span ? startDateStr.substring(startMatch.startIndex, startMatch.endIndex) : startDateStr;
    string finalEndDate = endMatch is regexp:Span ? endDateStr.substring(endMatch.startIndex, endMatch.endIndex) : endDateStr;

    return [finalStartDate, finalEndDate];
}

public function calculatePercentageChange(decimal current, decimal previous) returns decimal {
    if previous == 0.0d {
        return current > 0.0d ? 100.0d : 0.0d;
    }
    return ((current - previous) / previous) * 100.0d;
}

public function roundToTwoDecimals(decimal value) returns decimal {
    decimal multiplied = value * 100.0;
    int rounded = <int>multiplied;
    return <decimal>rounded / 100.0;
}

public function formatCurrency(decimal amount) returns string {
    decimal rounded = roundToTwoDecimals(amount);
    return string `${rounded.toString()}`;
}

public function formatPercentage(decimal percentage) returns string {
    decimal rounded = roundToTwoDecimals(percentage);
    string sign = rounded >= 0.0d ? "+" : "";
    return string `${sign}${rounded.toString()}%`;
}

public function getMonthName(string dateStr) returns string {
    string[] months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ];

    string[] parts = regexp:split(re `-`, dateStr);
    if parts.length() >= 2 {
        int|error monthNum = int:fromString(parts[1]);
        if monthNum is int && monthNum >= 1 && monthNum <= 12 {
            return months[monthNum - 1];
        }
    }
    return "Unknown";
}

public function getYear(string dateStr) returns string {
    string[] parts = regexp:split(re `-`, dateStr);
    if parts.length() >= 1 {
        return parts[0];
    }
    return "Unknown";
}
