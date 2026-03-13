import ballerina/time;

public function getCurrentTimestamp() returns string|error {
    time:Utc currentUtc = time:utcNow();
    time:Civil currentCivil = time:utcToCivil(currentUtc);
    return string `${currentCivil.year}-${currentCivil.month.toString().padZero(2)}-${currentCivil.day.toString().padZero(2)}T${currentCivil.hour.toString().padZero(2)}:${currentCivil.minute.toString().padZero(2)}:${currentCivil.second.toString().padZero(2)}Z`;
}

public function getFormattedCurrentTimeStamp() returns string|error {
    time:Zone? zone = time:getZone(timezone);
    if zone is time:Zone {
        time:Civil currentTime = zone.utcToCivil(time:utcNow());
        return string 
            `${currentTime.year.toString()}-${currentTime.month.toString().padZero(2)}-${currentTime.day.toString().padZero(2)} ${currentTime.hour.toString().padZero(2)}:${currentTime.minute.toString().padZero(2)}`;
    }
    return error("Invalid time zone");
}

function getTimeframeFilter() returns string|error {
    string normalizedTimeframe = timeframe.trim().toUpperAscii();
    
    if normalizedTimeframe == "ALL" {
        return "";
    }
    
    time:Utc currentUtc = time:utcNow();
    time:Civil currentCivil = time:utcToCivil(currentUtc);
    
    if normalizedTimeframe == "YESTERDAY" {
        time:Utc yesterdayUtc = time:utcAddSeconds(currentUtc, -86400.0d);
        time:Civil yesterdayCivil = time:utcToCivil(yesterdayUtc);
        string yesterday = string `${yesterdayCivil.year}-${yesterdayCivil.month.toString().padZero(2)}-${yesterdayCivil.day.toString().padZero(2)}T00:00:00Z`;
        string today = string `${currentCivil.year}-${currentCivil.month.toString().padZero(2)}-${currentCivil.day.toString().padZero(2)}T00:00:00Z`;
        return string `CreatedDate >= ${yesterday} AND CreatedDate < ${today}`;
    } else if normalizedTimeframe == "LAST_WEEK" {
        int? dayOfWeek = currentCivil.dayOfWeek;
        int daysToSubtract = dayOfWeek is int ? (dayOfWeek == 0 ? 6 : dayOfWeek - 1) : 0;
        decimal secondsToThisWeek = <decimal>(daysToSubtract * 86400);
        time:Utc thisWeekStartUtc = time:utcAddSeconds(currentUtc, -secondsToThisWeek);
        time:Utc lastWeekStartUtc = time:utcAddSeconds(thisWeekStartUtc, -604800.0d);
        time:Civil lastWeekStartCivil = time:utcToCivil(lastWeekStartUtc);
        time:Civil thisWeekStartCivil = time:utcToCivil(thisWeekStartUtc);
        string lastWeekStart = string `${lastWeekStartCivil.year}-${lastWeekStartCivil.month.toString().padZero(2)}-${lastWeekStartCivil.day.toString().padZero(2)}T00:00:00Z`;
        string thisWeekStart = string `${thisWeekStartCivil.year}-${thisWeekStartCivil.month.toString().padZero(2)}-${thisWeekStartCivil.day.toString().padZero(2)}T00:00:00Z`;
        return string `CreatedDate >= ${lastWeekStart} AND CreatedDate < ${thisWeekStart}`;
    } else if normalizedTimeframe == "LAST_MONTH" {
        int lastMonth = currentCivil.month == 1 ? 12 : currentCivil.month - 1;
        int lastMonthYear = currentCivil.month == 1 ? currentCivil.year - 1 : currentCivil.year;
        string lastMonthStart = string `${lastMonthYear}-${lastMonth.toString().padZero(2)}-01T00:00:00Z`;
        string thisMonthStart = string `${currentCivil.year}-${currentCivil.month.toString().padZero(2)}-01T00:00:00Z`;
        return string `CreatedDate >= ${lastMonthStart} AND CreatedDate < ${thisMonthStart}`;
    } else if normalizedTimeframe == "LAST_YEAR" {
        int lastYear = currentCivil.year - 1;
        string lastYearStart = string `${lastYear}-01-01T00:00:00Z`;
        string thisYearStart = string `${currentCivil.year}-01-01T00:00:00Z`;
        return string `CreatedDate >= ${lastYearStart} AND CreatedDate < ${thisYearStart}`;
    }
    
    return "";
}

public function buildSoqlQuery() returns string|error {
    string selectClause = string:'join(", ", ...fieldMapping);
    string query = string `SELECT ${selectClause} FROM Lead`;
    
    string[] whereConditions = [];
    
    if !includeConverted {
        whereConditions.push("IsConverted = false");
    }
    
    string timeframeFilter = check getTimeframeFilter();
    if timeframeFilter != "" {
        whereConditions.push(timeframeFilter);
    }
    
    if soqlFilter != "" {
        whereConditions.push(soqlFilter);
    }
    
    if enableIncrementalSync {
        string effectiveTimestamp = getEffectiveLastSyncTimestamp();
        if effectiveTimestamp != "" {
            whereConditions.push(string `LastModifiedDate > ${effectiveTimestamp}`);
        }
    }
    
    if whereConditions.length() > 0 {
        string whereClause = string:'join(" AND ", ...whereConditions);
        query = string `${query} WHERE ${whereClause}`;
    }
    
    if enableIncrementalSync {
        query = string `${query} ORDER BY LastModifiedDate ASC`;
    }
    
    return query;
}


