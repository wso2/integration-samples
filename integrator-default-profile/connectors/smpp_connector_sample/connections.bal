import ballerina/smpp;

final smpp:Client smppClient = check new (smscHost, systemId, password, port = smscPort, bindType = smpp:TRANSMITTER);
