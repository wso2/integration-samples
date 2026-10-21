import ballerina/log;

// Replace these three hooks with whatever the change should trigger.
isolated function onFileCreated(string path) {
    log:printInfo("file created", path = path);
}

isolated function onFileModified(string path) {
    log:printInfo("file modified", path = path);
}

isolated function onFileDeleted(string path) {
    log:printInfo("file deleted", path = path);
}
