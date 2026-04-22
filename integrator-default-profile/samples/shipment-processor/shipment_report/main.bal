import ballerina/http;
import ballerina/log;
import shipment_report.java.util as javautil;
import shipment_report.org.Utilities as utilities;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service / on httpDefaultListener {
    resource function get report() returns error|string|http:InternalServerError {
    do {
        javautil:Map result = utilities:Util_aggregateShipments();
        string response = "Aggregated shipment report is generated for" + result.keySet().toString();
        log:printInfo(response);
        return response;
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
    }
}
