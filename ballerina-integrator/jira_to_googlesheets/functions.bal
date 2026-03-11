import ballerina/time;
import ballerinax/jira;
import ballerina/os;

function convertBeanToIssueData(jira:IssueBean bean) returns IssueData {
    string summary = "";
    string statusName = "Unknown";
    AssigneeData? assignee = ();
    string created = "";
    string dueDate = "";
    
    record {| anydata...; |}? beanFields = bean.fields;
    if beanFields is record {} {
        map<anydata> fields = beanFields;
        
        if fields.hasKey("summary") && fields["summary"] is string {
            summary = <string>fields["summary"];
        }
        
        if fields.hasKey("created") && fields["created"] is string {
            created = formatIsoDateTime(<string>fields["created"]);
        }
        
        if fields.hasKey("duedate") {
            anydata duedateValue = fields["duedate"];
            if duedateValue is string {
                dueDate = duedateValue;
            }
        }
        
        if fields.hasKey("status") {
            anydata statusValue = fields["status"];
            if statusValue is record {} {
                map<anydata> statusMap = statusValue;
                if statusMap.hasKey("name") && statusMap["name"] is string {
                    statusName = <string>statusMap["name"];
                }
            }
        }
        
        if fields.hasKey("assignee") {
            anydata assigneeValue = fields["assignee"];
            if assigneeValue is record {} {
                map<anydata> assigneeMap = assigneeValue;
                if assigneeMap.hasKey("displayName") && assigneeMap["displayName"] is string {
                    string displayName = <string>assigneeMap["displayName"];
                    assignee = {displayName: displayName};
                }
            }
        }
    }

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
