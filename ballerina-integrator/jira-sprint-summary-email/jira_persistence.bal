import ballerina/log;
import ballerinax/jira;

// Check if a sprint has already been processed by looking for the label on any issue
function isSprintProcessed(int sprintId) returns boolean|error {
    return check isSprintProcessedByLabel(sprintId);
}

function isSprintProcessedByLabel(int sprintId) returns boolean|error {
    // Search for any issue in this sprint with the processed label
    string jqlQuery = string `sprint = ${sprintId} AND labels = "${processedSprintLabel}"`;

    jira:SearchAndReconcileResults searchResults = check jiraClient->/api/'3/search/jql(
        jql = jqlQuery,
        maxResults = 1
    );

    jira:IssueBean[] issues = searchResults.issues ?: [];
    boolean isProcessed = issues.length() > 0;

    if isProcessed {
        log:printDebug(string `Sprint ${sprintId} already processed (found label on issues)`);
    }

    return isProcessed;
}



// Mark a sprint as processed by adding a label to one issue
function markSprintAsProcessed(int sprintId) returns error? {
    check markSprintAsProcessedByLabel(sprintId);
}

function markSprintAsProcessedByLabel(int sprintId) returns error? {
    log:printInfo(string `Marking sprint ${sprintId} as processed in Jira`);

    // Get the first issue in the sprint (no need to paginate for this use case)
    jira:SearchAndReconcileResults searchResults = check jiraClient->/api/'3/search/jql(
        jql = string `project = ${jira.projectKey} AND sprint = ${sprintId}`,
        fields = ["key", "labels"],
        maxResults = 1
    );
    
    jira:IssueBean[] sprintIssues = searchResults.issues ?: [];

    if sprintIssues.length() == 0 {
        log:printWarn(string `No issues found in sprint ${sprintId} to mark as processed`);
        return;
    }

    // Add label to the first issue only (efficient approach)
    // This is enough to track that the sprint was processed
    jira:IssueBean firstIssue = sprintIssues[0];
    string? issueKey = firstIssue.key;

    if issueKey is () {
        log:printWarn("Could not get issue key to mark sprint as processed");
        return;
    }

    // Get current labels
    json issueJson = check firstIssue.cloneWithType();
    string[] currentLabels = [];

    if issueJson is map<json> {
        if issueJson.hasKey("fields") {
            json fieldsValue = issueJson["fields"];
            if fieldsValue is map<json> {
                if fieldsValue.hasKey("labels") {
                    json labelsValue = fieldsValue["labels"];
                    if labelsValue is json[] {
                        foreach json labelValue in labelsValue {
                            if labelValue is string {
                                currentLabels.push(labelValue);
                            }
                        }
                    }
                }
            }
        }
    }

    // Add the processed label if not already present
    if !currentLabels.some(label => label == processedSprintLabel) {
        currentLabels.push(processedSprintLabel);

        // Update the issue with the new labels
        jira:IssueUpdateDetails updatePayload = {
            fields: {
                "labels": currentLabels
            }
        };
        
        _ = check jiraClient->/api/'3/issue/[issueKey].put(updatePayload);
        log:printInfo(string `Added label "${processedSprintLabel}" to issue ${issueKey} for sprint ${sprintId}`);
    }
}


