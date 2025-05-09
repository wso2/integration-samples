import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function post payments(PaymentRequest request) returns PaymentStatus|error {
        string[] routingSlip = check lookupMessageSlip(request);
        Message message = {...request, routingSlip: routingSlip};
        Points points = {};
        if message.routingSlip.length() > 0 {
            final http:Client pointHandler = check new ("http://localhost:8081/loyaltyPoints");
            json payload = {
                storeCode: message.storeCode,
                mobileNumber: message.mobileNumber,
                routingSlip: message.routingSlip
            };
            http:Response targetType = check pointHandler->/points.post(payload);
        }
        return checkout(message, points);
    }
}
