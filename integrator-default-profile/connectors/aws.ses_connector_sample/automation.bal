import ballerina/log;
import ballerinax/aws.ses;

public function main() returns error? {
    do {
        ses:SendEmailOutput sendEmailResponse = check sesClient->sendEmail({fromEmailAddress: senderEmail, destination: {toAddresses: [recipientEmail]}, content: {simple: {subject: {data: "Hello from the WSO2 Integrator"}, body: {text: {data: "This message was sent with the Amazon SES connector."}}}}});
        log:printInfo(string `Email accepted by Amazon SES with message ID: ${sendEmailResponse.messageId.toString()}`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }

}
