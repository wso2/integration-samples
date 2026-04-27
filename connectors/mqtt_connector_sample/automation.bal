import ballerina/log;
import ballerina/mqtt;

public function main() returns error? {
    do {
        mqtt:DeliveryToken mqttDeliverytoken = check mqttClient->publish(mqttTopic, {payload: "Hello World".toBytes()});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
