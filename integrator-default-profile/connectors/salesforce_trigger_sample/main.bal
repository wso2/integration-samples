import ballerina/log;
import ballerinax/salesforce;

listener salesforce:Listener salesforceListener = new (auth = {username: sfUsername, password: sfPassword});

service salesforce:Service on salesforceListener {
    remote function onCreate(salesforce:EventData payload) returns error|() {
        do {
            log:printInfo(payload.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onUpdate(salesforce:EventData payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onDelete(salesforce:EventData payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onRestore(salesforce:EventData payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
