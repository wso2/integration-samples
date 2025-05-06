import ballerina/http;

final http:Client patientClient = check new ("http://api.patients.com.balmock.io");
