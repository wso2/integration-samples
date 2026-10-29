import ballerina/authzen;

final authzen:Client authzenClient = check new (string `${authzenPdpUrl}`);
