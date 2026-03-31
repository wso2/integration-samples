import ballerina/os;
import ballerina/time;
import ballerinax/jira;

function convertBeanToIssueData(jira:IssueBean bean) returns IssueData {
    string summary = "";
    string statusName = "Unknown";
    AssigneeData? assignee = ();
    string created = "";
    string dueDate = "";
    
    record {| anydata...; |}? beanFields = bean.fields;
    if beanFields is () {
        return {
            key: bean.key ?: "",
            fields: {
                summary,
                status: {name: statusName},
                assignee,
                created,
                dueDate
            }
        };
    }

    map<anydata> fields = beanFields;
    
    anydata summaryValue = fields["summary"];
    if summaryValue is string {
        summary = summaryValue;
    }
    
    anydata createdValue = fields["created"];
    if createdValue is string {
        created = formatIsoDateTime(createdValue);
    }
    
    anydata duedateValue = fields["duedate"];
    if duedateValue is string {
        dueDate = duedateValue;
    }
    
    anydata statusValue = fields["status"];
    if statusValue is record {} {
        map<anydata> statusMap = statusValue;
        anydata statusNameValue = statusMap["name"];
        if statusNameValue is string {
            statusName = statusNameValue;
        }
    }
    
    anydata assigneeValue = fields["assignee"];
    if assigneeValue is record {} {
        map<anydata> assigneeMap = assigneeValue;
        anydata displayNameValue = assigneeMap["displayName"];
        if displayNameValue is string {
            assignee = {displayName: displayNameValue};
        }
    }

    return {
        key: bean.key ?: "",
        fields: {
            summary,
            status: {name: statusName},
            assignee,
            created,
            dueDate
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
        string year = currentTime.year.toString();
        string month = currentTime.month.toString().padZero(2);
        string day = currentTime.day.toString().padZero(2);
        string hour = currentTime.hour.toString().padZero(2);
        string minute = currentTime.minute.toString().padZero(2);
        return string `${year}-${month}-${day} ${hour}:${minute}`;
    }
    return error("Invalid time zone: " + detectedTz);
}
