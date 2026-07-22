import ballerina/log;
import ballerina/mqtt;

public function main() returns error? {
    do {
        mqtt:DeliveryToken _ = check mqttClient->publish(mqttTopic, {
            payload: "25.5".toBytes(),
            qos: 2,
            retained: true
        });
        log:printInfo("Temperature published to MQTT broker", topic = mqttTopic, value = "25.5");

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
