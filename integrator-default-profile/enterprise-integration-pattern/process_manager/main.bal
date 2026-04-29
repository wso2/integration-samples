import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function post orders(OrderRequest orderReq) returns error? {
        OrderResponse response = check shopify->/admin/api/orders\.json.post(orderReq);
        string trackingNumber;
        if response.address.country == "United States" {
            FedexResponse fedexResp = check createFedexShipment(response);
            trackingNumber = fedexResp.trackingNumber;
        } else {
            DHLResponse dhlResp = check creeateDhlShipment(response);
            trackingNumber = dhlResp.trackingNumber;
        }
        future<error?> futureResult = start sendConfirmationMail(response.address.fullName, response.email, trackingNumber);
    }
}
