import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function post ticket(Ticket ticket) returns error? {
        if ticket.priority == 1 {
            http:Response response = check notificationChannel->/email/notify.post(ticket, targetType = http:Response);
        }
    }
}
