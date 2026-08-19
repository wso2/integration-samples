import ballerina/log;
import ballerinax/azure.storage.files;

listener files:Listener azFilesListener = new (shareName, auth = {accountName, accountKey}, pollingInterval = 5);

service /incoming on azFilesListener {
    @files:FunctionConfig {
        afterProcess: files:DELETE,
        afterError: {
            moveTo: "/failed"
        }
    }
    remote function onFileJson(json content) returns error? {
        do {
            log:printInfo(content.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
