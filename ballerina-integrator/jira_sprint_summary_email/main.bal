import ballerina/log;
import ballerina/io;
import ballerina/lang.runtime;
import ballerinax/jira;
import ballerinax/googleapis.gmail;

public function main() returns error? {
    io:println("✓ Jira Sprint Summary Automation started!");
    io:println(string `✓ Jira Base URL: ${jiraBaseUrl}`);
    io:println(string `✓ Jira Email: ${jiraEmail}`);
    io:println(string `✓ Polling interval: ${pollingIntervalSeconds} seconds`);
    io:println(string `✓ Monitoring project: ${jiraProjectKey}`);
    io:println("");
    
    // Test Jira connection
    io:println("Testing Jira connection...");
    do {
        _ = check jiraClient->/api/'3/myself;
        io:println("✓ Jira connection successful!");
    } on fail error e {
        io:println("✗ Failed to connect to Jira!");
        io:println("Please check your credentials:");
        io:println("  1. jiraEmail must be your Jira account email");
        io:println("  2. jiraApiToken must be a valid API token from https://id.atlassian.com/manage-profile/security/api-tokens");
        io:println("  3. jiraBaseUrl must be your Jira instance URL (e.g., https://yourcompany.atlassian.net)");
        return e;
    }
    io:println("");

    io:println(string `✓ Checking for completed sprints in project ${jiraProjectKey}...`);
    io:println("");
    
    map<boolean> processedSprints = {};
    
    while true {
        log:printInfo("Polling Jira for completed sprints...");
        
        error? result = checkCompletedSprints(processedSprints);
        if result is error {
            log:printError("Error checking sprints", 'error = result);
        }
        
        runtime:sleep(pollingIntervalSeconds);
    }
}

function checkCompletedSprints(map<boolean> processedSprints) returns error? {
    jira:SearchAndReconcileResults searchResults = check jiraClient->/api/'3/search/jql(
        jql = string `project = ${jiraProjectKey} AND sprint in closedSprints() ORDER BY updated DESC`,
        fields = ["*all"],
        maxResults = 100
    );

    jira:IssueBean[] issues = searchResults.issues ?: [];
    log:printInfo(string `JQL returned ${issues.length()} issue(s)`);
    map<Sprint> closedSprints = {};

    foreach jira:IssueBean issue in issues {
        json issueJson = check issue.cloneWithType();
        Sprint? sprint = extractSprint(issueJson);
        if sprint is Sprint {
            string sprintKey = string `${sprint.id}`;
            closedSprints[sprintKey] = sprint;
        } else {
            log:printDebug("Sprint not found in issue payload");
        }
    }

    log:printInfo(string `Found ${closedSprints.length()} closed sprint(s)`);

    foreach string sprintKey in closedSprints.keys() {
        Sprint sprint = <Sprint>closedSprints[sprintKey];

        if !processedSprints.hasKey(sprintKey) && isRecentlyCompleted(sprint) {
            log:printInfo(string `Processing newly completed sprint: ${sprint.name} (ID: ${sprint.id})`);

            SprintSummary summary = check generateSprintSummary(sprint);
            check sendSprintSummaryEmail(summary);

            processedSprints[sprintKey] = true;
            io:println(string `✓ Sent summary for sprint: ${sprint.name}`);
        }
    }
}

function generateSprintSummary(Sprint sprint) returns SprintSummary|error {
    log:printInfo("Generating sprint summary", sprintId = sprint.id);

    jira:SearchAndReconcileResults searchResults = check jiraClient->/api/'3/search/jql(
        jql = string `project = ${jiraProjectKey} AND sprint = ${sprint.id}`,
        fields = ["summary", "status", "assignee", "created"],
        expand = "changelog",
        maxResults = 100
    );

    jira:IssueBean[] sprintIssues = searchResults.issues ?: [];

    IssueDetails[] completedIssues = [];
    IssueDetails[] carriedOverIssues = [];

    foreach jira:IssueBean issue in sprintIssues {
        json issueJson = check issue.cloneWithType();
        IssueDetails issueDetail = check extractIssueDetails(issueJson);

        if issueDetail.statusCategory == "done" {
            completedIssues.push(issueDetail);
        } else {
            carriedOverIssues.push(issueDetail);
        }
    }

    string completedDateValue = sprint.completeDate ?: sprint.endDate ?: "N/A";

    AssigneeStats[] assigneeBreakdown = [];
    if includeAssigneeBreakdown {
        assigneeBreakdown = calculateAssigneeBreakdown(completedIssues, carriedOverIssues);
    }

    IssueDetails[] midSprintAdditions = [];
    if includeMidSprintAdditions {
        midSprintAdditions = check detectMidSprintAdditions(sprintIssues, sprint);
    }

    return {
        sprintName: sprint.name,
        sprintId: sprint.id,
        completedDate: completedDateValue,
        totalIssues: completedIssues.length() + carriedOverIssues.length(),
        completedIssues: completedIssues.length(),
        carriedOverIssues: carriedOverIssues.length(),
        completedIssuesList: completedIssues,
        carriedOverIssuesList: carriedOverIssues,
        assigneeBreakdown: assigneeBreakdown,
        midSprintAdditions: midSprintAdditions
    };
}

function sendSprintSummaryEmail(SprintSummary summary) returns error? {
    string recipientList = string:'join(", ", ...gmailRecipients);
    log:printInfo(string `Sending sprint summary email to ${gmailRecipients.length()} recipient(s): ${recipientList}`);

    string emailBody = formatEmailBody(summary);
    string emailSubject = formatEmailSubject(summary);

    gmail:MessageRequest messageRequest = {
        to: gmailRecipients,
        subject: emailSubject,
        bodyInHtml: emailBody
    };

    gmail:Message response = check gmailClient->/users/me/messages/send.post(messageRequest);
    log:printInfo("Email sent successfully", messageId = response.id);
}
