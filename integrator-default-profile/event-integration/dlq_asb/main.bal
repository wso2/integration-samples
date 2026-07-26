import ballerina/http;
import ballerina/log;
import ballerinax/asb;

public type NotificationJob record {|
    string channel;
    string recipient;
    string message;
|};

public enum DeliveryOutcome {
    DELIVERED,
    PROVIDER_UNAVAILABLE,
    INVALID_RECIPIENT
}

listener asb:Listener asbListener = new ({
    connectionString: connectionString,
    entityConfig: {queueName: queueName},
    receiveMode: asb:PEEK_LOCK,
    autoComplete: false
});

service /notifications on new http:Listener(8090) {
    resource function post send(NotificationJob job) returns error? {
        check notificationSender->send({body: job.toJsonString(), contentType: asb:TEXT});
        log:printInfo("Notification queued", channel = job.channel, recipient = job.recipient);
    }
}

service asb:Service on asbListener {
    remote function onMessage(asb:Message message, asb:Caller caller) returns error? {
        byte[] raw = check message.body.ensureType();
        string text = check string:fromBytes(raw);
        NotificationJob job = check text.fromJsonStringWithType();
        if job.recipient == "invalid" {
            check caller->deadLetter(
                deadLetterReason = "InvalidRecipient",
                deadLetterErrorDescription = "Recipient address is not deliverable");
            log:printInfo("Message dead-lettered", recipient = job.recipient);
        } else if job.recipient == "down" {
            check caller->abandon();
            log:printInfo("Message abandoned (provider down), will retry", recipient = job.recipient);
        } else {
            log:printInfo("Notification delivered", channel = job.channel, recipient = job.recipient);
            check caller->complete();
        }
    }
}
