import ballerina/log;
import ballerinax/ardoq;

public function main() returns error? {
    do {
        ardoq:PaginatedWorkspaceResponse workspaces = check ardoqClient->listWorkspaces();
        log:printInfo(workspaces.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
