import ballerina/http;
import ballerina/mime;
import ballerina/url;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function post incidents(IncidentRequest req) returns error? {
        string body = string `Incident ${req.incident.description} reported: ${req.incident.date} at ${req.incident.time}.`;
        http:Request twilioReq = new http:Request();
        string payload = "From=" + check url:encode("+15005550006", "utf-8") +
"&To=" + check url:encode(req.phoneNo, "utf-8") +
"&Body=" + check url:encode(body, "utf-8");
        () var1 = twilioReq.setTextPayload(payload, mime:APPLICATION_FORM_URLENCODED);
        http:Response
response = check twilio->/["2010-04-01"]/Accounts/["VBC1849a56d52g41s4b2b2cc004c0027aa8"]/Messages\.json.post(twilioReq, targetType = http:Response
);
    }
}
