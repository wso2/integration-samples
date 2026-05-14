import ballerina/file;
import ballerina/log;

listener file:Listener fileListener = new (path = "/tmp", recursive = false);

service file:Service on fileListener {
    remote function onModify(file:FileEvent event) returns error? {
        do {
            log:printInfo("File modified");
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
