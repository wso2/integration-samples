import ballerina/log;
import ballerinax/bitbucket;

public function main() returns error? {
    do {
        bitbucket:Account currentUser = check bitbucketClient->getCurrentUser();
        log:printInfo(currentUser.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
