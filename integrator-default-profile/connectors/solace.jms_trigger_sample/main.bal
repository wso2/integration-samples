import ballerina/log;
import ballerinax/solace.jms;

listener jms:Listener jmsListener = new (string `${solaceJmsUrl}`, messageVpn = "default", auth = {username: solaceJmsUsername, password: solaceJmsPassword});

@jms:ServiceConfig {queueName: solaceJmsQueueName, ackMode: jms:CLIENT_ACKNOWLEDGE}
service jms:Service on jmsListener {
    remote function onMessage(Message message, jms:Caller caller) returns jms:Error? {
        do {
            log:printInfo(message.toJsonString());
            check caller->ack(message);
        } on fail error err {
            return error("unhandled error", err);
        }
    }
}
