import ballerina/ai;
import ballerina/io;
import ballerina/pdf;
import ballerina/time;
import ballerinax/github;
import ballerinax/googleapis.gmail;

# Fetches the most recent 100 open issues and 100 open pull requests from the configured repository and
# flattens each into a simple row. Pull requests returned by the issues endpoint are skipped.
# + return - a flat list of rows for open issues and open pull requests, or an error
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_github_6.2.0.png"}
isolated function fetchRepoItems() returns RepoItemRow[]|error {
    github:Issue[] issues = check githubClient->/repos/[repoOwner]/[repoName]/issues(
        queries = {perPage: 100, state: "open", sort: "created", direction: "desc"}
    );
    github:PullRequestSimple[]|error|() pullsResult = githubClient->/repos/[repoOwner]/[repoName]/pulls(
        queries = {perPage: 100, state: "open", sort: "created", direction: "desc"}
    );
    if pullsResult is error {
        return pullsResult;
    }
    github:PullRequestSimple[] pulls;
    if pullsResult is () {
        pulls = [];
    } else {
        pulls = pullsResult;
    }

    RepoItemRow[] rows = [];

    foreach github:Issue issue in issues {
        if issue.pullRequest is github:IssuePullRequest {
            // This row is actually a pull request returned by the issues endpoint; skip it.
            continue;
        }
        rows.push(toIssueRow(issue));
    }

    foreach github:PullRequestSimple pull in pulls {
        rows.push(toPullRequestRow(pull));
    }

    return rows;
}

isolated function toIssueRow(github:Issue issue) returns RepoItemRow {
    string[] labels = [];
    foreach github:IssueLabels label in issue.labels {
        if label is record {|string name?; anydata...;|} {
            string? name = label.name;
            if name is string {
                labels.push(name);
            }
        }
    }

    string author = "";
    github:NullableSimpleUser|() user = issue.user;
    if user is github:SimpleUser {
        author = user.login;
    }

    string assignee = "";
    github:NullableSimpleUser|() issueAssignee = issue.assignee;
    if issueAssignee is github:SimpleUser {
        assignee = issueAssignee.login;
    }

    return {
        'type: "issue",
        number: issue.number,
        title: issue.title,
        author: author,
        assignee: assignee,
        labels: labels,
        commentCount: issue.comments,
        createdDate: issue.createdAt,
        ageDays: computeAgeDays(issue.createdAt),
        url: issue.htmlUrl
    };
}

isolated function toPullRequestRow(github:PullRequestSimple pull) returns RepoItemRow {
    string[] labels = [];
    foreach github:PullRequestLabels label in pull.labels {
        labels.push(label.name);
    }

    string author = "";
    github:NullableSimpleUser|() user = pull.user;
    if user is github:SimpleUser {
        author = user.login;
    }

    string assignee = "";
    github:NullableSimpleUser|() pullAssignee = pull.assignee;
    if pullAssignee is github:SimpleUser {
        assignee = pullAssignee.login;
    }

    return {
        'type: "pr",
        number: pull.number,
        title: pull.title,
        author: author,
        assignee: assignee,
        labels: labels,
        commentCount: 0,
        createdDate: pull.createdAt,
        ageDays: computeAgeDays(pull.createdAt),
        url: pull.htmlUrl
    };
}

isolated function computeAgeDays(string createdAt) returns int {
    time:Utc|error createdUtc = time:utcFromString(createdAt);
    if createdUtc is error {
        return 0;
    }
    time:Utc now = time:utcNow();
    decimal diffSeconds = time:utcDiffSeconds(now, createdUtc);
    int ageDays = <int>(diffSeconds / 86400);
    return ageDays;
}

# Converts a print-ready HTML report into a PDF file and returns its local file path.
# + html - the print-ready HTML report content
# + return - the local file path of the generated PDF, or an error
@ai:AgentTool
isolated function convertToPdf(string html) returns string|error {
    byte[] pdfBytes = check pdf:parseHtml(html, pageSize = pdf:A4);
    string pdfPath = "./monthly-report.pdf";
    check io:fileWriteBytes(pdfPath, pdfBytes);
    return pdfPath;
}

# Emails the generated PDF as an attachment to the configured recipient, with the summary in the body.
# Sends exactly one email.
# + pdfPath - the local file path of the generated PDF
# + summary - the report summary to include in the email body
# + return - a confirmation message, or an error
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.0.1.png"}
isolated function emailReport(string pdfPath, string summary) returns string|error {
    gmail:MessageRequest message = {
        to: [recipientEmail],
        subject: emailSubject,
        bodyInHtml: string `<p>${summary}</p>`,
        attachments: [
            {mimeType: "application/pdf", name: "monthly-report.pdf", path: pdfPath}
        ]
    };

    gmail:Message _ = check gmailClient->/users/me/messages/send.post(message);
    return "Email sent to " + recipientEmail;
}
