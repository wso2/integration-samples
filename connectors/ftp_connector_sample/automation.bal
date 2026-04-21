import ballerina/ftp;
import ballerina/log;

public function main() returns error? {
    do {
        json result = check ftpClient->getJson("/data/sample.json");
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
