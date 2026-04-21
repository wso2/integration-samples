import ballerina/udp;

final udp:Client udpClient = check new (localHost = udpLocalHost);
