type SupportTicket record {
    string ticketId;
    string status;
    string assignedGroup;
};

type Requester record {
    string name;
    string email;
};

type AiAnalysis record {
    string category;
    string urgency;
    string summary;
    string routingGroup;
};

type SupportTicketRequest record {
    string ticketSource;
    string customerId;
    Requester requester;
    string ticketType;
    string subject;
    string details;
    string priority;
    AiAnalysis aiAnalysis;
};
