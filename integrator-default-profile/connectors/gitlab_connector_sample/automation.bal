import ballerina/log;
import ballerinax/gitlab;

public function main() returns error? {
    do {
        gitlab:UserPublic currentUser = check gitlabClient->getCurrentUser();
        log:printInfo(currentUser.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
