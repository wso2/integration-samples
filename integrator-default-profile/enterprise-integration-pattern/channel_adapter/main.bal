import ballerinax/jira;

public function main() returns error? {
    jira:Project result = check jiraAdapter->getProject("EI-Patterns-With-Ballerina");
}
