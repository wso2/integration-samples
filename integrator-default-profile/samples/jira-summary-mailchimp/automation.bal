import ballerina/log;
import ballerinax/jira;

public function main() returns error? {
    do {
        log:printInfo("Fetching issues from Jira");

        jira:IssuePickerSuggestions pickerResults = check jiraClient->/api/'3/issue/picker.get(currentJQL = jiraConfig.jqlQuery);
        jira:IssuePickerSuggestionsIssueType[]? sections = pickerResults.sections;

        Issue[] issues = [];

        if sections is jira:IssuePickerSuggestionsIssueType[] {
            foreach jira:IssuePickerSuggestionsIssueType section in sections {
                jira:SuggestedIssue[]? suggestedIssues = section.issues;
                if suggestedIssues is jira:SuggestedIssue[] {
                    foreach jira:SuggestedIssue suggestedIssue in suggestedIssues {
                        string? key = suggestedIssue.key;
                        if key is string {
                            jira:IssueBean issueDetails = check jiraClient->/api/'3/issue/[key].get();

                            record {|anydata...;|}? fields = issueDetails.fields;
                            if fields is record {|anydata...;|} {
                                Issue issue = check mapToIssue(key, fields);
                                issues.push(issue);
                            }
                        }
                    }
                }
            }
        }

        if issues.length() <= 0 {
            log:printInfo("No issues found");
        } else {
            log:printInfo(string `Found ${issues.length()} issue(s)`);

            check sendIssueSummary(issues);
        }
    } on fail error e {
        log:printError("Error occurred", 'error = e);
    }
}
