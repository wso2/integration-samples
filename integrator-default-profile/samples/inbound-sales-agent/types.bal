// Email / thread types used as agent input and for Gmail processing

public type EmailMessage record {
    string sender;
    string subject;
    string body;
    string date;
};

public type InboundEmailRequest record {
    string senderName;
    string senderEmail;
    string subject;
    string threadId;
    string originalMessageIdHeader;
    EmailMessage[] threadMessages;
};

// Salesforce lookup result for a Lead or Contact

public type LeadOrContact record {
    string id;
    string recordType;
    string name;
    string company;
    string status;
};

public type LeadQueryResult record {
    string Id;
    string Name?;
    string Company?;
    string Status?;
    string Description?;
};

public type ContactQueryResult record {
    string Id;
    string Name?;
};

// The Description field shared by Leads and Contacts

public type DescriptionRecord record {
    string Id;
    string Description?;
};
