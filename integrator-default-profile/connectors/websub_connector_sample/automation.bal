import ballerina/log;
import ballerina/websubhub;

public function main() returns error? {
    do {
        websubhub:Acknowledgement result = check websubhubPublisherclient->publishUpdate(string `${websubTopic}`, <json>{"action": "publish", "mode": "remote-hub"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
