import ballerina/log;
import ballerinax/trigger.twilio;

listener twilio:Listener twilioListener = new (listenOn = listenerPort);

service twilio:SmsStatusService on twilioListener {
    remote function onAccepted(twilio:SmsStatusChangeEventWrapper event) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onQueued(twilio:SmsStatusChangeEventWrapper event) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onSending(twilio:SmsStatusChangeEventWrapper event) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onSent(twilio:SmsStatusChangeEventWrapper event) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onFailed(twilio:SmsStatusChangeEventWrapper event) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onDelivered(twilio:SmsStatusChangeEventWrapper event) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onUndelivered(twilio:SmsStatusChangeEventWrapper event) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onReceiving(twilio:SmsStatusChangeEventWrapper event) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onReceived(twilio:SmsStatusChangeEventWrapper event) returns error|() {
        do {
            log:printInfo(event.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
