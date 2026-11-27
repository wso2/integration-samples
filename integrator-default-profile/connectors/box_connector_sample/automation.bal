import ballerina/log;
import ballerinax/box;

public function main() returns error? {
    do {
        box:UserFull currentUser = check boxClient->getCurrentUser();
        log:printInfo(currentUser.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
