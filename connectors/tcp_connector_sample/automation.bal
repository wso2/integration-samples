import ballerina/log;
import ballerina/tcp;

public function main() returns error? {
    do {
        var result = check tcpClient->writeBytes("Hello World".toBytes());
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
