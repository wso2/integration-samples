import ballerina/time;
import ballerina/log;
import ballerinax/jira;

// Time formatting
function getFormattedTimeStamp(time:Utc timeValue) returns string {
    time:Zone? zone = time:getZone(email.timeZone);
    if zone is time:Zone {
        time:Civil currentTime = zone.utcToCivil(timeValue);
        string month = currentTime.month < 10 ? string `0${currentTime.month}` : currentTime.month.toString();
        string day = currentTime.day < 10 ? string `0${currentTime.day}` : currentTime.day.toString();
        string hour = currentTime.hour < 10 ? string `0${currentTime.hour}` : currentTime.hour.toString();
        string minute = currentTime.minute < 10 ? string `0${currentTime.minute}` : currentTime.minute.toString();
        return string `${currentTime.year}-${month}-${day} ${hour}:${minute}`;
    }
    return "N/A";
}

// Issue extraction
function extractIssueDetails(json issue) returns IssueDetails|error {
    map<json> issueMap = check issue.ensureType();
    map<json> fieldsMap = check issueMap["fields"].ensureType();
    map<json> statusMap = check fieldsMap["status"].ensureType();
    map<json> statusCategoryMap = check statusMap["statusCategory"].ensureType();

    string? assignee = ();
    if fieldsMap.hasKey("assignee") && fieldsMap["assignee"] is map<json> {
        map<json> assigneeMap = <map<json>>fieldsMap["assignee"];
        if assigneeMap.hasKey("displayName") {
            assignee = check assigneeMap["displayName"].ensureType();
        }
    }

    return {
        key: check issueMap["key"].ensureType(),
        summary: check fieldsMap["summary"].ensureType(),
        status: check statusMap["name"].ensureType(),
        statusCategory: check statusCategoryMap["key"].ensureType(),
        assignee: assignee,
        created: fieldsMap.hasKey("created") && fieldsMap["created"] is string ? <string>fieldsMap["created"] : ()
    };
}

// Sprint extraction
function extractSprint(json issue) returns Sprint? {
    if issue is map<json> {
        if issue.hasKey("fields") {
            json fieldsValue = issue["fields"];
            if fieldsValue is map<json> {
                if fieldsValue.hasKey("sprint") {
                    json sprintValue = fieldsValue["sprint"];
                    log:printDebug(string `Found 'sprint' field with value type: ${sprintValue is map<json> ? "map" : (sprintValue is json[] ? "array" : "other")}`);
                    if sprintValue is map<json> {
                        return toSprint(sprintValue);
                    }
                    if sprintValue is json[] {
                        if sprintValue.length() > 0 {
                            json latest = sprintValue[sprintValue.length() - 1];
                            if latest is map<json> {
                                return toSprint(latest);
                            }
                        }
                    }
                }

                // Fallback for Jira instances where sprint is exposed only via custom fields
                foreach string fieldKey in fieldsValue.keys() {
                    if fieldKey.startsWith("customfield_") {
                        json customFieldValue = fieldsValue[fieldKey];
                        Sprint? sprint = toSprintFromValue(customFieldValue);
                        if sprint is Sprint {
                            log:printDebug(string `Found sprint in custom field: ${fieldKey}`);
                            return sprint;
                        }
                    }
                }
                
                log:printDebug("No sprint field found in issue, available fields: " + fieldsValue.keys().toString());
            }
        }
    }
    return ();
}

function toSprintFromValue(json value) returns Sprint? {
    if value is map<json> {
        return toSprint(value);
    }

    if value is string {
        return parseLegacySprintString(value);
    }

    if value is json[] {
        int i = value.length() - 1;
        while i >= 0 {
            json item = value[i];
            if item is map<json> {
                Sprint? sprint = toSprint(item);
                if sprint is Sprint {
                    return sprint;
                }
            }
            if item is string {
                Sprint? sprint = parseLegacySprintString(item);
                if sprint is Sprint {
                    return sprint;
                }
            }
            i -= 1;
        }
    }

    return ();
}

function parseLegacySprintString(string value) returns Sprint? {
    int? idStartPos = value.indexOf("id=");
    int? nameStartPos = value.indexOf("name=");
    if !(idStartPos is int) || !(nameStartPos is int) {
        return ();
    }
    int idStart = idStartPos;
    int nameStart = nameStartPos;

    int? idEndPos = value.indexOf(",", idStart);
    if !(idEndPos is int) {
        return ();
    }
    int idEnd = idEndPos;

    string idText = value.substring(idStart + 3, idEnd).trim();
    int|error parsedId = int:fromString(idText);
    if parsedId is error {
        return ();
    }
    int id = parsedId;

    int nameEnd = value.length();
    int? nameEndPos = value.indexOf(",", nameStart);
    if nameEndPos is int {
        nameEnd = nameEndPos;
    }
    string sprintName = value.substring(nameStart + 5, nameEnd).trim();
    if sprintName == "" {
        return ();
    }

    string? startDate = ();
    string? completeDate = ();
    string? endDate = ();
    foreach string marker in ["startDate=", "completeDate=", "endDate="] {
        int? pos = value.indexOf(marker);
        if pos is int {
            int valueStart = pos + marker.length();
            int valueEnd = value.length();
            int? endPos = value.indexOf(",", valueStart);
            if endPos is int {valueEnd = endPos;}
            string raw = value.substring(valueStart, valueEnd).trim();
            if raw != "<null>" && raw != "" {
                if marker == "startDate=" {startDate = raw;} 
                else if marker == "completeDate=" {completeDate = raw;} 
                else {endDate = raw;}
            }
        }
    }

    return {
        id: id,
        name: sprintName,
        startDate: startDate,
        completeDate: completeDate,
        endDate: endDate
    };
}

function toSprint(map<json> sprintData) returns Sprint? {
    if !(sprintData.hasKey("id") && sprintData.hasKey("name")) {
        return ();
    }

    int id;
    json idValue = sprintData["id"];
    if idValue is int {
        id = idValue;
    } else {
        return ();
    }

    json nameValue = sprintData["name"];
    if nameValue is string {
        string sprintName = nameValue;
        
        string? startDate = ();
        if sprintData.hasKey("startDate") {
            json startDateValue = sprintData["startDate"];
            if startDateValue is string {
                startDate = startDateValue;
            }
        }

        string? completeDate = ();
        if sprintData.hasKey("completeDate") {
            json completeDateValue = sprintData["completeDate"];
            if completeDateValue is string {
                completeDate = completeDateValue;
            }
        }

        string? endDate = ();
        if sprintData.hasKey("endDate") {
            json endDateValue = sprintData["endDate"];
            if endDateValue is string {
                endDate = endDateValue;
            }
        }

        return {
            id: id,
            name: sprintName,
            startDate: startDate,
            completeDate: completeDate,
            endDate: endDate
        };
    }

    return ();
}



// Date parsing
function parseJiraDateTime(string dateText) returns time:Utc|error {
    time:Utc|error parsed = time:utcFromString(dateText);
    if parsed is time:Utc {
        return parsed;
    }

    int textLength = dateText.length();
    if textLength >= 5 {
        string sign = dateText.substring(textLength - 5, textLength - 4);
        if sign == "+" || sign == "-" {
            string hourPart = dateText.substring(textLength - 4, textLength - 2);
            string minutePart = dateText.substring(textLength - 2, textLength);
            string prefix = dateText.substring(0, textLength - 5);
            string normalized = string `${prefix}${sign}${hourPart}:${minutePart}`;

            parsed = time:utcFromString(normalized);
            if parsed is time:Utc {
                return parsed;
            }
        }
    }

    return parsed;
}

// Mid-sprint additions detection
function detectMidSprintAdditions(jira:IssueBean[] sprintIssues, Sprint sprint) returns IssueDetails[]|error {
    IssueDetails[] midSprintAdditions = [];
    
    string? sprintStartDate = sprint.startDate;
    if sprintStartDate is () {
        log:printWarn("Sprint start date not available, cannot detect mid-sprint additions", sprintId = sprint.id);
        return midSprintAdditions;
    }
    
    time:Utc|error sprintStartTime = parseJiraDateTime(sprintStartDate);
    if sprintStartTime is error {
        log:printWarn(string `Could not parse sprint start date: ${sprintStartDate}`);
        return midSprintAdditions;
    }
    
    foreach jira:IssueBean issue in sprintIssues {
        json|error issueJson = issue.cloneWithType();
        if issueJson is error {
            continue;
        }
        
        IssueDetails|error issueDetail = extractIssueDetails(issueJson);
        if issueDetail is error {
            continue;
        }

        // Reuse changelog data from initial search (already expanded)
        boolean isMidSprintAddition = false;

        string? sprintAddedDate = getSprintAddedDate(issueJson, sprint.id, sprint.name);
        if sprintAddedDate is string {
            time:Utc|error addedTime = parseJiraDateTime(sprintAddedDate);
            if addedTime is time:Utc {
                time:Seconds addedDiff = time:utcDiffSeconds(addedTime, sprintStartTime);
                if addedDiff > 0d {
                    isMidSprintAddition = true;
                    log:printDebug(string `Mid-sprint addition detected (by changelog): ${issueDetail.key} (added ${sprintAddedDate})`);
                }
            }
        }

        if !isMidSprintAddition {
            string? issueCreated = issueDetail.created;
            if issueCreated is string {
                time:Utc|error issueCreatedTime = parseJiraDateTime(issueCreated);
                if issueCreatedTime is time:Utc {
                    time:Seconds createdDiff = time:utcDiffSeconds(issueCreatedTime, sprintStartTime);
                    if createdDiff > 0d {
                        isMidSprintAddition = true;
                        log:printDebug(string `Mid-sprint addition detected (by creation): ${issueDetail.key} (created ${issueCreated})`);
                    }
                }
            }
        }

        if isMidSprintAddition {
            midSprintAdditions.push(issueDetail);
        }
    }
    
    log:printInfo(string `Found ${midSprintAdditions.length()} mid-sprint addition(s)`, sprintId = sprint.id);
    return midSprintAdditions;
}

function getSprintAddedDate(json issue, int sprintId, string sprintName) returns string? {
    if !(issue is map<json>) {
        return ();
    }
    
    map<json> issueMap = <map<json>>issue;
    if !issueMap.hasKey("changelog") {
        return ();
    }
    
    json changelogValue = issueMap["changelog"];
    if !(changelogValue is map<json>) {
        return ();
    }
    
    map<json> changelog = <map<json>>changelogValue;
    if !changelog.hasKey("histories") {
        return ();
    }
    
    json historiesValue = changelog["histories"];
    if !(historiesValue is json[]) {
        return ();
    }
    
    json[] histories = <json[]>historiesValue;
    
    string? latestAddedDate = ();

    foreach json historyValue in histories {
        if !(historyValue is map<json>) {
            continue;
        }
        
        map<json> history = <map<json>>historyValue;
        string? historyCreated = ();
        if history.hasKey("created") {
            json createdValue = history["created"];
            if createdValue is string {
                historyCreated = createdValue;
            }
        }

        if historyCreated is () {
            continue;
        }

        if !history.hasKey("items") {
            continue;
        }
        
        json itemsValue = history["items"];
        if !(itemsValue is json[]) {
            continue;
        }
        
        json[] items = <json[]>itemsValue;
        
        foreach json itemValue in items {
            if !(itemValue is map<json>) {
                continue;
            }
            
            map<json> item = <map<json>>itemValue;

            if !item.hasKey("field") || !(item["field"] is string) || (<string>item["field"]).trim().toLowerAscii() != "sprint" {
                continue;
            }

            string fromValue = (item.hasKey("from") && item["from"] is string) ? <string>item["from"] : "";
            string fromStringValue = (item.hasKey("fromString") && item["fromString"] is string) ? <string>item["fromString"] : "";
            string toValue = (item.hasKey("to") && item["to"] is string) ? <string>item["to"] : "";
            string toStringValue = (item.hasKey("toString") && item["toString"] is string) ? <string>item["toString"] : "";

            boolean inFrom = sprintExistsInChangeValues(fromValue, fromStringValue, sprintId, sprintName);
            boolean inTo = sprintExistsInChangeValues(toValue, toStringValue, sprintId, sprintName);

            if !inFrom && inTo {
                latestAddedDate = <string>historyCreated;
            }
        }
    }

    return latestAddedDate;
}

function sprintExistsInChangeValues(string idValue, string textValue, int sprintId, string sprintName) returns boolean {
    string sprintIdText = sprintId.toString();

    string trimmedIdValue = idValue.trim();
    if trimmedIdValue != "" {
        if trimmedIdValue == sprintIdText {
            return true;
        }

        if trimmedIdValue.includes(string `,${sprintIdText},`) ||
            trimmedIdValue.startsWith(string `${sprintIdText},`) ||
            trimmedIdValue.endsWith(string `,${sprintIdText}`) {
            return true;
        }

        int|error parsedId = int:fromString(trimmedIdValue);
        if parsedId is int && parsedId == sprintId {
            return true;
        }
    }

    string trimmedTextValue = textValue.trim();
    if trimmedTextValue == "" {
        return false;
    }

    string normalizedText = trimmedTextValue.toLowerAscii();
    string normalizedSprintName = sprintName.trim().toLowerAscii();

    if normalizedSprintName != "" && normalizedText.includes(normalizedSprintName) {
        return true;
    }

    if trimmedTextValue.includes(string `id=${sprintIdText}`) {
        return true;
    }

    if trimmedTextValue == sprintIdText ||
        trimmedTextValue.includes(string `,${sprintIdText},`) ||
        trimmedTextValue.startsWith(string `${sprintIdText},`) ||
        trimmedTextValue.endsWith(string `,${sprintIdText}`) {
        return true;
    }

    return false;
}



// Date formatting for Jira JQL
function getJiraFormattedDate(time:Utc timeValue) returns string {
    time:Civil civilTime = time:utcToCivil(timeValue);
    string year = civilTime.year.toString();
    string month = civilTime.month < 10 ? string `0${civilTime.month}` : civilTime.month.toString();
    string day = civilTime.day < 10 ? string `0${civilTime.day}` : civilTime.day.toString();
    string hour = civilTime.hour < 10 ? string `0${civilTime.hour}` : civilTime.hour.toString();
    string minute = civilTime.minute < 10 ? string `0${civilTime.minute}` : civilTime.minute.toString();
    return string `${year}-${month}-${day} ${hour}:${minute}`;
}

// Check if sprint was completed recently
function isSprintCompletedRecently(Sprint sprint, time:Utc cutoffTime) returns boolean {
    string? completeDateValue = sprint.completeDate ?: sprint.endDate;
    if completeDateValue is () {
        log:printDebug(string `Sprint ${sprint.id} has no completion date, skipping`);
        return false;
    }
    
    time:Utc|error completeTime = parseJiraDateTime(completeDateValue);
    if completeTime is error {
        log:printWarn(string `Could not parse completion date for sprint ${sprint.id}: ${completeDateValue}`);
        return false;
    }
    
    time:Seconds timeDiff = time:utcDiffSeconds(completeTime, cutoffTime);
    return timeDiff >= 0d;
}

// Assignee breakdown calculation
function calculateAssigneeBreakdown(IssueDetails[] completedIssues, IssueDetails[] carriedOverIssues) returns AssigneeStats[] {
    map<AssigneeStats> assigneeMap = {};

    foreach IssueDetails issue in completedIssues {
        string assigneeName = issue.assignee ?: "Unassigned";
        
        if assigneeMap.hasKey(assigneeName) {
            AssigneeStats existingStats = assigneeMap.get(assigneeName);
            assigneeMap[assigneeName] = {
                assigneeName: assigneeName,
                completedCount: existingStats.completedCount + 1,
                carriedOverCount: existingStats.carriedOverCount,
                totalCount: existingStats.totalCount + 1
            };
        } else {
            assigneeMap[assigneeName] = {
                assigneeName: assigneeName,
                completedCount: 1,
                carriedOverCount: 0,
                totalCount: 1
            };
        }
    }

    foreach IssueDetails issue in carriedOverIssues {
        string assigneeName = issue.assignee ?: "Unassigned";
        
        if assigneeMap.hasKey(assigneeName) {
            AssigneeStats existingStats = assigneeMap.get(assigneeName);
            assigneeMap[assigneeName] = {
                assigneeName: assigneeName,
                completedCount: existingStats.completedCount,
                carriedOverCount: existingStats.carriedOverCount + 1,
                totalCount: existingStats.totalCount + 1
            };
        } else {
            assigneeMap[assigneeName] = {
                assigneeName: assigneeName,
                completedCount: 0,
                carriedOverCount: 1,
                totalCount: 1
            };
        }
    }

    AssigneeStats[] breakdown = assigneeMap.toArray();
    
    AssigneeStats[] sortedBreakdown = from AssigneeStats stats in breakdown
                                       order by stats.totalCount descending
                                       select stats;
    
    return sortedBreakdown;
}
