import ballerina/http;
import ballerina/mime;
import ballerina/url;

function sendReminder(Attendee attendee, string eventName, string date) returns error? {
    string body = string `Hi ${attendee.name}, looking forward to meet you at the ${eventName} on ${date}`;
    string payload = "From=" + check url:encode("+15005550006", "utf-8") +
"&To=" + check url:encode(attendee.number, "utf-8") +
"&Body=" + check url:encode(body, "utf-8");
    http:Request twilioReq = new http:Request();
    () var1 = twilioReq.setTextPayload(payload, contentType = mime:APPLICATION_FORM_URLENCODED);
    http:Response response = check twilio->/["2010-04-01"]/Accounts/["VAC1829a53d52f41b4b2b1cc003c0026aa8"]/Messages\.json.post(twilioReq, targetType = http:Response);
}
