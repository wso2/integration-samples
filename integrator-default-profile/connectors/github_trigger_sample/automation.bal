import ballerina/log;
import ballerinax/github;

configurable string owner = ?;
configurable string repo = ?;

public function main() returns error? {
    do {
        github:Issue githubIssue = check githubClient->/repos/[owner]/[repo]/issues.post({
            title: "Test webhook"
        });
        log:printInfo("Issue created", number = githubIssue.number, url = githubIssue.html_url);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
