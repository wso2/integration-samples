import ballerina/log;
import ballerinax/asb;

listener asb:Listener asbListener = new (connectionString = string `${connectionString}${queueName}Endpoint=sb://<NAMESPACE>.servicebus.windows.net/;SharedAccessKeyName=<KEY_NAME>;SharedAccessKey=<KEY_VALUE>`, entityConfig = {queueName: queueName});

service asb:Service on asbListener {
    remote function onMessage(asb:Message message) returns error? {
        do {
            log:printInfo(message.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
