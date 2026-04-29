import ballerina/file;
import ballerina/io;
import ballerina/log;
import ballerina/time;
import ballerinax/slack;

listener file:Listener directoryService = new (path = directoryToListen, recursive = false);

service file:Service on directoryService {
    remote function onModify(file:FileEvent event) {
        do {
            string filePath = event.name;
            log:printInfo("File modified:" + event.name);
            if event.name.endsWith(".log") {
                string[] logFileLines = check io:fileReadLines(filePath);
                if logFileLines.length() > 0 {
                    string lastLog = logFileLines[logFileLines.length() - 1];
                    if lastLog.startsWith("ERROR:") {
                        log:printInfo("Error detected in file:" + filePath);
                        string timestamp = time:utcToString(time:utcNow());
                        string slackMessage = "Error notification\n" + timestamp + ": " + lastLog;
                        slack:ChatPostMessageResponse slackResponse = check slackClient->/chat\.postMessage.post({channel: slackChannel, text: slackMessage});
                        if slackResponse.ok {
                            log:printInfo("Error reported successfully");
                        } else {
                            log:printError("Error reporting failed");
                        }
                    }
                }
            }
        } on fail error err {
            // handle error
            log:printError("Error notification failed: " + err.message());
        }
    }

}
