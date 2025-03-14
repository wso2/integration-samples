import ballerina/data.xmldata;
import ballerina/http;
import ballerina/io;
import ballerina/log;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service / on httpDefaultListener {

    resource function post convert(@http:Payload json payload) returns xml|http:BadRequest {
        do {
            // Log the received JSON request
            io:println("Received JSON request: ", payload.toJsonString());

            // Convert JSON to XML.
            xml convertedXml = check xmldata:fromJson(payload);

            // Log the converted XML.
            io:println("Converted to XML: ", convertedXml.toString());
            return convertedXml;

        } on fail error err {
            log:printError("Failed to convert JSON to XML: " + err.message());
            return http:BAD_REQUEST;
        }
    }
}
