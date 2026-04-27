import ballerina/log;
import ballerina/mqtt;

listener mqtt:Listener mqttListener = new (string `${mqttBrokerUrl}mqtt://localhost:1883`, string `${mqttClientId}unique_client_001`, string `${mqttTopic}topic1`);

service mqtt:Service on mqttListener {
    remote function onMessage(mqtt:Message message) returns error? {
        do {
            log:printInfo(message.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
