import ballerina/mqtt;

configurable string mqttServerUri = mqtt:DEFAULT_URL;
configurable string mqttClientId = "ballerina-mqtt-client";
configurable string mqttTopic = "sensors/temperature";
