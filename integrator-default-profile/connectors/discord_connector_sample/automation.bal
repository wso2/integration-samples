import ballerina/log;
import ballerinax/discord;

public function main() returns error? {
    do {
        discord:MessageResponse discordMessageresponse = check discordClient->/channels/[string `1234567890123456789`]/messages.post({
            contentType: "application/x-www-form-urlencoded"
        }, {content: "Hello from WSO2 Integrator! This message was sent using the ballerinax/discord connector."});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
