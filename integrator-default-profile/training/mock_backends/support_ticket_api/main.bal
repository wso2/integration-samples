import ballerina/http;

listener http:Listener ep = new (port = 8080);

service /support on ep {

    resource function post request(@http:Payload SupportTicketRequest ticketRequest) returns SupportTicket {
        string ticketId = generateTicketId();

        return {ticketId: ticketId, status: "created", assignedGroup: ticketRequest.aiAnalysis.routingGroup};
    }
}
