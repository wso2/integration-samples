import ballerina/http;
import ballerina/mime;

final http:Client zohoClient = check new ("http://content.zohoapis.com.balmock.io", retryConfig = {count: 3, interval: 1, statusCodes: [404, 408, 500]}
);

listener http:Listener httpListener = new (port = 8080);

service /crm on httpListener {
    resource function post bulkUploadLeads(CsvRequest csvRequest) returns ZohoResponse|error {
        http:Request request = new http:Request();
        () var1 = request.addHeader("X-CRM_ORG", csvRequest.org);
        () var2 = request.addHeader("feature", "bulk-write");
        () var3 = request.setFileAsPayload("./ftpincoming/" + csvRequest.filename, contentType = mime:MULTIPART_FORM_DATA);
        ZohoResponse result = check zohoClient->/crm/v5/upload.post(request);
        return result;
    }
}
