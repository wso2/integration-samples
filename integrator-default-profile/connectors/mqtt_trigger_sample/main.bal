import ballerina/log;
import ballerina/mqtt;
import ballerina/uuid;

configurable string broker = mqtt:DEFAULT_URL;
const TOPIC = "sensors/temperature";

listener mqtt:Listener mqttListener = new (
    broker,
    uuid:createType1AsString(),
    TOPIC,
    {manualAcks: true}
);

service on mqttListener {
    remote function onMessage(mqtt:Message message, mqtt:Caller caller) returns error? {
        string payload = check string:fromBytes(message.payload);
        log:printInfo("Temperature message received from MQTT broker", topic = message.topic, payload = payload);
        float temperature = check float:fromString(payload);

        if temperature > 30.0 {
            log:printWarn("High temperature alert!", temp = temperature);
        } else {
            log:printInfo("Temperature normal", temp = temperature);
        }

        // Acknowledge the message
        check caller->complete();
    }

    remote function onError(mqtt:Error err) returns error? {
        log:printError("Error processing message", 'error = err);
    }
}