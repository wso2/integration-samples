import ballerina/mqtt;

final mqtt:Client mqttClient = check new (string `${mqttServerUri}`, string `${mqttClientId}`);
