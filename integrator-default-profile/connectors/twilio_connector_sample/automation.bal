import ballerina/log;
import ballerinax/twilio;

public function main() returns error? {
    do {
        // initiate call from twilio
        twilio:Call twilioCall = check twilioClient->createCall({
            To: toNumber,
            From: fromNumber,
            Url: twimlUrl,
            StatusCallback: statusCallbackUrl,
            StatusCallbackMethod: "POST",
            StatusCallbackEvent: ["initiated", "ringing", "answered", "completed"]
        });
        string? callSid = twilioCall?.sid;
        log:printInfo("Call initiated", sid = callSid ?: "");

        // initiate a message from twilio
        twilio:Message twilioMessage = check twilioClient->createMessage({To: toNumber, From: fromNumber, Body: "Hello from WSO2 Integrator!"});
        string? messageSid = twilioMessage?.sid;
        log:printInfo("Message sent", sid = messageSid ?: "");

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
