import ballerina/log;
import ballerinax/solace;

listener solace:Listener solaceListener = new ("solaceHost", messageVpn = "solaceVpnName", auth = {username: "solaceUsername", password: "solacePassword"});

@solace:ServiceConfig {
    queueName: "solaceQueueName",
    sessionAckMode: "AUTO_ACKNOWLEDGE"
}
service solace:Service on solaceListener {
    remote function onMessage(SolaceMessage message) returns error? {
        do {
            log:printInfo(message.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
