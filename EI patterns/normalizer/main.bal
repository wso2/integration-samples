import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function post ticket(@http:Payload json|xml request) returns string|error {
        if request is json {
            json normalizedRequest = normalize(check request.subject, check request.comment);
            ZendeskResponse zendeskResponse = check zendeskClient->/api/v2/tickets.post(normalizedRequest);
            return zendeskResponse.ticket.url;
        } else {
            json normalizedRequest = normalize((request/<subject>).data(), (request/<comment>).data());
            ZendeskResponse zendeskResponse = check zendeskClient->/api/v2/tickets.post(normalizedRequest);
            return zendeskResponse.ticket.url;
        }
    }
}
