import ballerina/os;
import ballerina/time;
import ballerinax/jira;

function convertBeanToIssueData(jira:IssueBean bean) returns IssueData {
    record {| anydata...; |}? beanFields = bean.fields;
    if beanFields is () {
        return {
            key: bean.key ?: "",
            fields: {
                summary: "",
                status: {name: "Unknown"},
                assignee: (),
                created: "",
                dueDate: ""
            }
        };
    }

    JiraIssueFields|error jiraFields = beanFields.cloneWithType();
    if jiraFields is error {
        return {
            key: bean.key ?: "",
            fields: {
                summary: "",
                status: {name: "Unknown"},
                assignee: (),
                created: "",
                dueDate: ""
            }
        };
    }

    string summary = jiraFields.summary ?: "";
    string statusName = jiraFields.status?.name ?: "Unknown";
    
    AssigneeData? assignee = ();
    record {| string displayName; |}? assigneeRecord = jiraFields.assignee;
    if assigneeRecord is record {| string displayName; |} {
        assignee = {displayName: assigneeRecord.displayName};
    }
    
    string created = "";
    string? createdValue = jiraFields.created;
    if createdValue is string {
        created = formatIsoDateTime(createdValue);
    }
    
    string dueDate = jiraFields.duedate ?: "";

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
