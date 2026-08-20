import ballerina/log;
import ballerinax/solace;

listener solace:Listener solaceListener = new (string `${solaceHost}`, messageVpn = "default", transacted = false, auth = {username: solaceUsername, password: solacePassword});

@solace:ServiceConfig {queueName: solaceQueueName, ackMode: "AUTO_ACK"}
service solace:Service on solaceListener {
    remote function onMessage(Message message, solace:Caller caller) returns solace:Error?|error? {
        do {
            log:printInfo(message.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
