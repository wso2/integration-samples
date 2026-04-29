import ballerina/log;

public function main() returns error? {
    do {
        check udpClient->sendDatagram({
            remoteHost: udpRemoteHost,
            remotePort: udpRemotePort,
            data: "Hello UDP World".toBytes()
        });
        log:printInfo("Datagram sent successfully");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
