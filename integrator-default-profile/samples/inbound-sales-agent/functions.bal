import ballerina/ai;
import ballerinax/googleapis.gmail;
import ballerinax/salesforce;

# Searches the Stratus product documentation knowledge base and returns the most relevant chunks.
# + query - the prospect's question or topic to search for
# + return - the most relevant excerpts from the product docs, or an error
@ai:AgentTool
isolated function searchProductDocs(string query) returns string|error {
    ai:QueryMatch[] matches = check productDocsKnowledgeBase.retrieve(query, 4);
    if matches.length() == 0 {
        return "No relevant product documentation was found for this query.";
    }
    string[] excerpts = [];
    foreach ai:QueryMatch 'match in matches {
        excerpts.push('match.chunk.content.toString());
    }
    return string:'join("\n\n---\n\n", ...excerpts);
}

# Searches Salesforce Leads and Contacts by email address.
# + email - the email address to search for
# + return - the matching lead or contact's Id, type, name, company and status, or nothing if not found
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_salesforce_8.7.0.png"}
isolated function findLeadOrContact(string email) returns LeadOrContact?|error {
    string escapedEmail = escapeSoqlLiteral(email);
    // Converted leads can't be updated, so skip them and fall through to the contact they became
    string leadQuery = string `SELECT Id, Name, Company, Status FROM Lead WHERE Email = '${escapedEmail}' AND IsConverted = false LIMIT 1`;
    stream<LeadQueryResult, error?> leadResults = check salesforceClient->query(leadQuery);
    record {|LeadQueryResult value;|}|error? leadNext = leadResults.next();
    check leadResults.close();
    if leadNext is record {|LeadQueryResult value;|} {
        LeadQueryResult lead = leadNext.value;
        string company = lead.Company ?: "";
        string status = lead.Status ?: "";
        string name = lead.Name ?: "";
        return {id: lead.Id, recordType: "Lead", name, company, status};
    }

    string contactQuery = string `SELECT Id, Name FROM Contact WHERE Email = '${escapedEmail}' LIMIT 1`;
    stream<ContactQueryResult, error?> contactResults = check salesforceClient->query(contactQuery);
    record {|ContactQueryResult value;|}|error? contactNext = contactResults.next();
    check contactResults.close();
    if contactNext is record {|ContactQueryResult value;|} {
        ContactQueryResult contact = contactNext.value;
        string name = contact.Name ?: "";
        return {id: contact.Id, recordType: "Contact", name, company: "", status: ""};
    }

    return ();
}

# Creates a new Salesforce Lead for a prospect.
# + firstName - the prospect's first name
# + lastName - the prospect's last name
# + email - the prospect's email address
# + company - the prospect's company name
# + description - a summary of the conversation and the prospect's use case
# + return - the new Lead's Id, or an error
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_salesforce_8.7.0.png"}
isolated function createLead(string firstName, string lastName, string email, string company, string description) returns string|error {
    salesforce:CreationResponse response = check salesforceClient->create("Lead", {
        "FirstName": firstName,
        "LastName": lastName,
        "Email": email,
        "Company": company,
        "Description": description,
        "LeadSource": "Email",
        "Status": "Open - Not Contacted"
    });
    return response.id;
}

# Appends a dated conversation summary to an existing lead's or contact's Description.
# + recordId - the Salesforce Id returned by findLeadOrContact
# + recordType - the recordType returned by findLeadOrContact, either "Lead" or "Contact"
# + description - the new conversation summary to append
# + return - an error if the update failed
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_salesforce_8.7.0.png"}
isolated function updateLeadOrContact(string recordId, string recordType, string description) returns error? {
    if recordType != "Lead" && recordType != "Contact" {
        return error(string `Unsupported record type: ${recordType}. Use "Lead" or "Contact".`);
    }
    DescriptionRecord existingRecord = check salesforceClient->getById(recordType, recordId);
    string currentDescription = existingRecord.Description ?: "";
    string today = getTodayDateString();
    string updatedDescription = currentDescription == "" ?
        string `[${today}] ${description}` :
        string `${currentDescription}` + "\n" + string `[${today}] ${description}`;
    check salesforceClient->update(recordType, recordId, {"Description": updatedDescription});
}

# Creates a Salesforce Task to flag a prospect for sales rep follow-up.
# + whoId - the Salesforce Id of the lead or contact this task relates to
# + subject - a short subject line for the task
# + description - a short summary of what the prospect asked for
# + return - an error if the task could not be created
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_salesforce_8.7.0.png"}
isolated function createFollowUpTask(string whoId, string subject, string description) returns error? {
    string dueDate = getNextBusinessDayDateString();
    salesforce:CreationResponse _ = check salesforceClient->create("Task", {
        "WhoId": whoId,
        "Subject": subject,
        "Description": description,
        "ActivityDate": dueDate,
        "Priority": "High"
    });
}

# Sends a plain-text email reply to the prospect within the original Gmail thread.
# Call this only when the prospect should receive a reply right now.
# + recipientEmail - the prospect's email address
# + subject - the original message's subject; "Re: " is added automatically if not already present
# + threadId - the Gmail thread id to reply within
# + originalMessageIdHeader - the Message-ID header of the message being replied to
# + replyBody - the plain-text email reply body to send
# + return - an error if sending failed
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.2.1.png"}
isolated function sendEmailReply(string recipientEmail, string subject, string threadId,
        string originalMessageIdHeader, string replyBody) returns error? {
    string replySubject = subject.toLowerAscii().startsWith("re:") ? subject : string `Re: ${subject}`;
    gmail:MessageRequest replyMessage = {
        to: [recipientEmail],
        subject: replySubject,
        bodyInText: replyBody,
        threadId,
        initialMessageId: originalMessageIdHeader,
        references: originalMessageIdHeader != "" ? [originalMessageIdHeader] : []
    };
    gmail:Message _ = check gmailClient->/users/me/messages/send.post(replyMessage);
}
