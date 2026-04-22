import ballerina/log;
import ballerinax/jira;

public function main() returns error? {
    do {
        jira:CreatedIssue jiraCreatedissue = check jiraClient->/api/'3/issue.post({fields: {"summary": "Integration test issue", "project": {"key": "PROJ"}, "issuetype": {"name": "Task"}}});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
