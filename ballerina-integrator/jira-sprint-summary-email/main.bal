import ballerina/log;
import ballerina/time;
import ballerinax/jira;
import ballerinax/googleapis.gmail;

public function main() returns error? {
    log:printInfo("Jira Sprint Summary Automation started!");
    log:printInfo(string `Jira Base URL: ${jiraBaseUrl}`);
    log:printInfo(string `Lookback window: ${lookbackHours} hours`);
    log:printInfo(string `Monitoring project: ${jiraProjectKey}`);
    
    // Test Jira connection
    log:printInfo("Testing Jira connection...");
    do {
        _ = check jiraClient->/api/'3/myself;
        log:printInfo("Jira connection successful!");
    } on fail error e {
        log:printError("Failed to connect to Jira!");
        log:printError("Please check your credentials:");
        log:printError("  1. jiraEmail must be your Jira account email");
        log:printError("  2. jiraApiToken must be a valid API token from https://id.atlassian.com/manage-profile/security/api-tokens");
        log:printError("  3. jiraBaseUrl must be your Jira instance URL (e.g., https://yourcompany.atlassian.net)");
        return e;
    }

    log:printInfo(string `Checking for completed sprints in project ${jiraProjectKey}...`);
    
    check checkCompletedSprints();
    
    log:printInfo("Sprint summary automation completed successfully!");
}

function checkCompletedSprints() returns error? {
    // Calculate time window: only fetch sprints completed within the lookback window
    time:Utc currentTime = time:utcNow();
    decimal lookbackSeconds = lookbackHours * 3600;
    time:Utc cutoffTime = time:utcAddSeconds(currentTime, -lookbackSeconds);
    string cutoffDateString = getJiraFormattedDate(cutoffTime);
    
    log:printInfo(string `Searching for sprints completed after ${cutoffDateString} (window: ${lookbackHours} hours)`);
    
    jira:SearchAndReconcileResults searchResults = check jiraClient->/api/'3/search/jql(
        jql = string `project = ${jiraProjectKey} AND sprint in closedSprints() AND updated >= "${cutoffDateString}" ORDER BY updated DESC`,
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
            // Only process sprints that were actually completed within our time window
            if isSprintCompletedRecently(sprint, cutoffTime) {
                string sprintKey = string `${sprint.id}`;
                closedSprints[sprintKey] = sprint;
            }
        } else {
            log:printDebug("Sprint not found in issue payload");
        }
    }

    log:printInfo(string `Found ${closedSprints.length()} recently closed sprint(s)`);

    foreach string sprintKey in closedSprints.keys() {
        Sprint sprint = <Sprint>closedSprints[sprintKey];

        // Check if already processed using Jira label
        boolean|error jiraCheckResult = isSprintProcessed(sprint.id);
        
        boolean alreadyProcessed = false;
        if jiraCheckResult is error {
            log:printWarn(string `Failed to check if sprint ${sprint.id} was already processed`, 'error = jiraCheckResult);
        } else {
            alreadyProcessed = jiraCheckResult;
        }

        if !alreadyProcessed {
            log:printInfo(string `Processing newly completed sprint: ${sprint.name} (ID: ${sprint.id})`);

            do {
                SprintSummary summary = check generateSprintSummary(sprint);
                check sendSprintSummaryEmail(summary);

                // Mark as processed in Jira
                error? markResult = markSprintAsProcessed(sprint.id);
                if markResult is error {
                    log:printWarn(string `Failed to mark sprint ${sprint.id} as processed in Jira`, 'error = markResult);
                }
                
                log:printInfo(string `Sent summary for sprint: ${sprint.name}`, sprintId = sprint.id);
            } on fail error e {
                log:printError(string `Failed to process sprint ${sprint.name} (ID: ${sprint.id})`, 'error = e, sprintId = sprint.id);
                // Continue to next sprint instead of aborting
            }
        } else {
            log:printDebug(string `Sprint ${sprint.name} (ID: ${sprint.id}) already processed, skipping`);
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
