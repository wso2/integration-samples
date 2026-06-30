import ballerinax/rabbitmq;
import ballerinax/slack;

listener rabbitmq:Listener rabbitmqListener = new (string `${rabbitmqHost}`, rabbitmqPort);

service "ballerina.social.media" on rabbitmqListener {
    remote function onMessage(RabbitMQAnydataMessage message, rabbitmq:Caller caller) returns error? {
        do {
            slack:ChatPostMessageResponse slackChatpostmessageresponse = check slackClient->/chat\.postMessage.post({
                channel: "New post creations",
                text: message.content.leaderId + "just posted"
            });
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
