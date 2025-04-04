import ballerina/ftp;
import ballerina/io;
import ballerina/log;

listener ftp:Listener WeatherData = new (path = "/data/observations/metar/decoded/", auth = {credentials: {username: ftpUser, password: ftpPassword}}, host = ftpHost, pollingInterval = 10, fileNamePattern = "(.*).TXT");

service ftp:Service on WeatherData {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        do {
            foreach ftp:FileInfo addedFile in event.addedFiles {
                stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
                record {|byte[] value;|}? content = check fileStream.next();
                if content is record {|byte[] value;|} {
                    string fileContent = check string:fromBytes(content.value);
                    int? firstLineIndex = fileContent.indexOf("\n");
                    if firstLineIndex is int {
                        string location = fileContent.substring(0, firstLineIndex);
                        log:printInfo("Recieved weather information from: " + location);
                    }
                } else {
                    log:printError("Failed to read weather content");
                }
            }
        } on fail error err {
            // handle error
            log:printError("Error: " + err.message());
        }
    }
}
