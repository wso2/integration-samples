import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /shipments on httpListener {
    resource function get [Country country]/[string trackingNumber]/status() returns string|error {
        if country is UK {
            DhlUkResponse response = check dhl->/parceluk/tracking/v1/shipments.get(trackingNumber = trackingNumber);
            return response.shipments[0].status.status;
        } else {
            DhlDpiResponse response = check dhl->/dpi/tracking/v1/trackings/[trackingNumber].get();
            return response.events[0].status;
        }
    }
}
