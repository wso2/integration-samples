import ballerina/log;
import ballerinax/slack;

public function main() returns error? {
    do {
        slack:ChatPostMessageResponse slackChatpostmessageresponse = check slackClient->/chat\.postMessage.post({channel: "general", text: "Hello from WSO2 Integrator! This message was sent via the Slack connector."});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
