import ballerina/time;
import ballerinax/jira;
import ballerina/log;
import ballerina/os;

function convertBeanToIssueData(jira:IssueBean bean) returns IssueData {
    string summary = "";
    string statusName = "Unknown";
    AssigneeData? assignee = ();
    string created = "";
    string dueDate = "";

    log:printInfo("Processing issue bean: " + bean.toString());
    
    // Safely extract fields from the bean using index notation for dynamic records
    if bean.fields !is () {
        var fields = bean.fields;
        log:printInfo("Fields found: " + fields.toString());
        
        // Extract summary
        if fields["summary"] is string {
            summary = <string>fields["summary"];
            log:printDebug("Summary: " + summary);
        }
        
        // Extract created
        if fields["created"] is string {
            created = formatIsoDateTime(<string>fields["created"]);
            log:printDebug("Created: " + created);
        }
        
        // Extract dueDate
        if fields["duedate"] is string {
            dueDate = <string>fields["duedate"];
            log:printDebug("Due Date: " + dueDate);
        }
        
        // Extract status
        if fields["status"] !is () {
            var status = fields["status"];
            if status is record {} && status["name"] is string {
                statusName = <string>status["name"];
                log:printDebug("Status: " + statusName);
            }
        }
        
        // Extract assignee
        if fields["assignee"] !is () {
            var assigneeRec = fields["assignee"];
            if assigneeRec is record {} && assigneeRec["displayName"] is string {
                string displayName = <string>assigneeRec["displayName"];
                assignee = {displayName: displayName};
                log:printDebug("Assignee: " + displayName);
            }
        }
    } else {
        log:printDebug("No fields found in bean");
    }

    log:printInfo(string `Converted issue - Key: ${bean.key ?: "EMPTY"}, Summary: ${summary}, Status: ${statusName}`);

    return {
        key: bean.key ?: "",
        fields: {
            summary: summary,
            status: {name: statusName},
            assignee: assignee,
            created: created,
            dueDate: dueDate
        }
    };
}

function formatIsoDateTime(string isoDateTime) returns string {
    if isoDateTime.length() >= 16 {
        return isoDateTime.substring(0, 10) + " " + isoDateTime.substring(11, 16);
    }
    return isoDateTime;
}

function getFormattedCurrentTimeStamp() returns string|error {
    string detectedTz = timezone;
    if detectedTz == "" {
        detectedTz = "UTC";
    }
    
    string? tzEnv = os:getEnv("TZ");
    if tzEnv is string && tzEnv != "" {
        detectedTz = tzEnv;
    }
    
    time:Zone? zone = time:getZone(detectedTz);
    if zone is time:Zone {
        time:Civil currentTime = zone.utcToCivil(time:utcNow());
        return string `${currentTime.year.toString()}-${currentTime.month.toString().padZero(2)}-${currentTime.day.toString().padZero(2)} ${currentTime.hour.toString().padZero(2)}:${currentTime.minute.toString().padZero(2)}`;
    }
    return error("Invalid time zone: " + detectedTz);
}

function mapIssueToRow(IssueData issue) returns SheetRow {
    string key = issue.key;
    string summary = issue.fields.summary;
    string status = issue.fields.status.name;
    string assignee = issue.fields.assignee?.displayName ?: "Unassigned";
    string created = issue.fields.created;
    string dueDate = issue.fields.dueDate;

    return [key, summary, status, assignee, created, dueDate];
}
