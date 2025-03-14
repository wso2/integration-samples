import ballerina/log;
import ballerinax/googleapis.gmail;

public function main() returns error? {
    do {
        log:printInfo("Sending email to: " + receiverEmail);

        // construct and send the email message
        gmail:Message gmailMessage = check gmailClient->/users/[gmailUserId]/messages/send.post({
            'from: senderEmail,
            to: [receiverEmail],
            subject: "Morning Update",
            bodyInText: "Hello! This is your daily update from '" + gmailUserId + "'. Have a great day!"
        });

        log:printInfo("Email sent successfully: Email ID = " + gmailMessage.id);
    } on fail error e {
        log:printError("Error: ", 'error = e);
        return e;
    }
}
