import ballerina/file;
import ballerina/log;

listener file:Listener fileListener = new (path = "{watchPath}", recursive = false);

service file:Service on fileListener {
    remote function onCreate(file:FileEvent event) {
        log:printInfo(event.toJsonString());
    }

    remote function onDelete(file:FileEvent event) {
    }

    remote function onModify(file:FileEvent event) {
    }

}
