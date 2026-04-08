import ballerina/log;
import ballerinax/asana;

public function main() returns error? {
    do {
        asana:WorkspaceCompactResponse asanaWorkspacecompactresponse = check asanaClient->/workspaces.get();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
