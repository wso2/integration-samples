import ballerina/tcp;

final tcp:Client tcpClient = check new (string `${tcpHost}`, tcpPort);
