import ballerina/log;
import ballerina/tcp;

public function main() returns error? {
    do {
        check tcpClient->writeBytes("Hello World".toBytes());
        log:printInfo("Bytes sent successfully");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
