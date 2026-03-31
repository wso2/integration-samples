import ballerina/time;

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
    
    if whereConditions.length() > 0 {
        string whereClause = string:'join(" AND ", ...whereConditions);
        query = string `${query} WHERE ${whereClause}`;
    }
    
    return query;
}
