import ballerinax/trigger.twilio;
import ballerina/log;

listener twilio:Listener twilioListener = new (listenerPort);

// Call status service
service twilio:CallStatusService on twilioListener {

    remote function onQueued(twilio:CallStatusEventWrapper event) returns error? {
        log:printInfo("Call queued", callSid = event.CallSid ?: "");
    }

    remote function onRinging(twilio:CallStatusEventWrapper event) returns error? {
        log:printInfo("Call ringing", callSid = event.CallSid ?: "");
    }

    remote function onInProgress(twilio:CallStatusEventWrapper event) returns error? {
        log:printInfo("Call in progress", callSid = event.CallSid ?: "");
    }

    remote function onCompleted(twilio:CallStatusEventWrapper event) returns error? {
        log:printInfo("Call completed",
                      callSid = event.CallSid ?: "",
                      duration = event.CallDuration ?: "");
    }

    remote function onBusy(twilio:CallStatusEventWrapper event) returns error? {
        log:printInfo("Call busy", callSid = event.CallSid ?: "");
    }

    remote function onFailed(twilio:CallStatusEventWrapper event) returns error? {
        log:printInfo("Call failed", callSid = event.CallSid ?: "");
    }

    remote function onNoAnswer(twilio:CallStatusEventWrapper event) returns error? {
        log:printInfo("Call no answer", callSid = event.CallSid ?: "");
    }

    remote function onCanceled(twilio:CallStatusEventWrapper event) returns error? {
        log:printInfo("Call canceled", callSid = event.CallSid ?: "");
    }
}

// SMS status service
service twilio:SmsStatusService on twilioListener {

    remote function onAccepted(twilio:SmsStatusChangeEventWrapper event) returns error? {
        log:printInfo("SMS accepted", messageSid = event.MessageSid ?: "");
    }

    remote function onQueued(twilio:SmsStatusChangeEventWrapper event) returns error? {
        log:printInfo("SMS queued", messageSid = event.MessageSid ?: "");
    }

    remote function onSending(twilio:SmsStatusChangeEventWrapper event) returns error? {
        log:printInfo("SMS sending", messageSid = event.MessageSid ?: "");
    }

    remote function onSent(twilio:SmsStatusChangeEventWrapper event) returns error? {
        log:printInfo("SMS sent", messageSid = event.MessageSid ?: "");
    }

    remote function onFailed(twilio:SmsStatusChangeEventWrapper event) returns error? {
        log:printInfo("SMS failed", messageSid = event.MessageSid ?: "");
    }

    remote function onDelivered(twilio:SmsStatusChangeEventWrapper event) returns error? {
        log:printInfo("SMS delivered", messageSid = event.MessageSid ?: "");
    }

    remote function onUndelivered(twilio:SmsStatusChangeEventWrapper event) returns error? {
        log:printInfo("SMS undelivered", messageSid = event.MessageSid ?: "");
    }

    remote function onReceiving(twilio:SmsStatusChangeEventWrapper event) returns error? {
        log:printInfo("SMS receiving", messageSid = event.MessageSid ?: "");
    }

    remote function onReceived(twilio:SmsStatusChangeEventWrapper event) returns error? {
        string fromNumber = event.From ?: "";
        string msgBody = event.Body ?: "";
        log:printInfo("SMS received",
                      messageSid = event.MessageSid ?: "",
                      'from = fromNumber,
                      body = msgBody);
    }
}