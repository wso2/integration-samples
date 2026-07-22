import ballerinax/trigger.twilio;
import ballerina/http;
import ballerina/log;

configurable int port = 8090;
configurable int twimlPort = 8091;

listener twilio:Listener twilioListener = new (port);

// Serves TwiML so Twilio knows what to say when the call is answered
// ngrok must forward to localhost:8091 for this endpoint
service /twiml on new http:Listener(twimlPort) {
    resource function post voice() returns http:Response {
        http:Response twimlResponse = new;
        twimlResponse.setHeader("Content-Type", "application/xml");
        twimlResponse.setPayload(string `<?xml version="1.0" encoding="UTF-8"?><Response><Say>${callMessage}</Say></Response>`);
        log:printInfo(`TwiML ${callMessage} response sent`);
        return twimlResponse;
    }
}