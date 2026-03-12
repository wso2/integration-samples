import ballerina/http;
import ballerina/log;
import ballerinax/trigger.github;

listener github:Listener githubListener = new ({webhookSecret: githubWebhookSecret});

service github:IssuesService on githubListener {
    remote function onOpened(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onClosed(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onReopened(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onAssigned(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onUnassigned(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onLabeled(github:IssuesEvent payload) returns error|() {
        do {
            github:Label? label = payload.label;
            if label is github:Label {
                string labelName = label.name;
                int? labelIndex = triggerLabels.indexOf(labelName);
                if labelIndex is int {
                    // Check if repository URL is in the configured list
                    string repositoryHtmlUrl = payload.repository.html_url;
                    int? repositoryIndex = githubRepositories.indexOf(repositoryHtmlUrl);
                    if repositoryIndex is () {
                        // Repository not in the configured list, skip processing
                        log:printInfo("Repository not in configured list, skipping case creation", repositoryUrl = repositoryHtmlUrl);
                        return;
                    }
                    
                    // Label exists in triggerLabels and repository is configured - create Salesforce case
                    github:Issue issue = payload.issue;
                    string issueTitle = issue.title;
                    string? issueBody = issue.body;
                    string issueDescription = issueBody is string ? issueBody : "";
                    string issueHtmlUrl = issue.html_url;

                    SalesforceCase salesforceCase = {
                        Subject: issueTitle,
                        Description: issueDescription,
                        Status: caseStatus,
                        Priority: casePriority,
                        OwnerId: caseOwnerId,
                        Type: caseRecordType,
                        GitHub_Issue_URL__c: issueHtmlUrl
                    };

                    _ = check salesforceClient->create(sObjectName = "Case", sObject = salesforceCase);
                }
            }
        } on fail error err {
            github:Issue issue = payload.issue;
            string issueHtmlUrl = issue.html_url;
            
            if err is http:ApplicationResponseError {
                map<anydata> errorDetail = err.detail();
                int statusCode = <int>errorDetail["statusCode"];
                
                if statusCode == 401 {
                    log:printError("Salesforce authentication failed - please check your salesforceAccessToken in Config.toml");
                } else if statusCode == 400 {
                    log:printError("Failed to create Salesforce case - please check your caseOwnerId, the owner ID may be invalid", githubIssueUrl = issueHtmlUrl);
                } else {
                    log:printError("Failed to create Salesforce case", statusCode = statusCode, githubIssueUrl = issueHtmlUrl);
                }
            } else {
                string errorMessage = err.message();
                log:printError("Unexpected error while creating Salesforce case", errorMsg = errorMessage, githubIssueUrl = issueHtmlUrl);
            }
            
            return error("Failed to create Salesforce case", err);
        }
    }

    remote function onUnlabeled(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
