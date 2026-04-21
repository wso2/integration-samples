import ballerina/log;
import ballerinax/hubspot.crm.engagements.email;

public function main() returns error? {
    do {
        email:SimplePublicObject emailSimplepublicobject = check emailClient->/.post({associations: [], properties: {"hs_timestamp": "2024-01-15T10:30:00Z", "hubspot_owner_id": "12345", "hs_email_direction": "EMAIL", "hs_email_status": "SENT", "hs_email_subject": "Follow-up on your inquiry", "hs_email_text": "Thank you for reaching out. We will get back to you shortly."}});
        log:printInfo(emailSimplepublicobject.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
