import ballerina/log;
import ballerinax/github;

public function main() returns error? {
    do {
        github:Issue issueResponse = check githubClient->/repos/[string `wso2`]/[string `ballerina-library`]/issues.post({title: "Add GitHub connector integration sample", body: "This issue was created using the ballerinax/github connector via WSO2 Integrator.", labels: ["enhancement"]});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
