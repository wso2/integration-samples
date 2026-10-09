import ballerina/time;

public function getFormattedCurrentTimeStamp() returns string|error {
    time:Zone? zone = time:getZone(timezone);
    if zone is time:Zone {
        time:Civil currentTime = zone.utcToCivil(time:utcNow());
        int seconds = <int>currentTime.second;
        return string 
            `${currentTime.year.toString()}-${currentTime.month.toString().padZero(2)}-${currentTime.day.toString().padZero(2)} ${currentTime.hour.toString().padZero(2)}:${currentTime.minute.toString().padZero(2)}:${seconds.toString().padZero(2)}`;
    }
    return error("Invalid time zone");
}

function getTimeframeFilter() returns string|error {
    match timeframe {
        ALL => {
            return "";
        }
        YESTERDAY => {
            return "CreatedDate >= YESTERDAY";
        }
        LAST_WEEK => {
            return "CreatedDate >= LAST_WEEK";
        }
        LAST_MONTH => {
            return "CreatedDate >= LAST_MONTH";
        }
        LAST_YEAR => {
            return "CreatedDate >= LAST_YEAR";
        }
        _ => {
            return "";
        }
    }
}

function sanitizeSoqlFilter(string filter) returns string|error {
    string trimmedFilter = filter.trim();
    
    if trimmedFilter == "" {
        return "";
    }
    
    string lowerFilter = trimmedFilter.toLowerAscii();
    
    string[] dangerousKeywords = [
        "delete",
        "insert",
        "update",
        "merge",
        "upsert",
        "undelete"
    ];
    
    foreach string keyword in dangerousKeywords {
        if lowerFilter.includes(keyword) {
            return error(string `SOQL filter contains dangerous keyword: "${keyword}". Only SELECT queries are allowed.`);
        }
    }
    
    return trimmedFilter;
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
        string sanitizedFilter = check sanitizeSoqlFilter(soqlFilter);
        if sanitizedFilter != "" {
            whereConditions.push(sanitizedFilter);
        }
    }
    
    if whereConditions.length() > 0 {
        string whereClause = string:'join(" AND ", ...whereConditions);
        query = string `${query} WHERE ${whereClause}`;
    }
    
    return query;
}
