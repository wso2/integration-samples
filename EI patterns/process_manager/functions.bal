function createFedexShipment(OrderResponse response) returns FedexResponse|error {
    ShipmentRequest fedexReq = {
        amount: response.total,
        currency: response.currency,
        personName: response.address.fullName,
        email: response.email,
        address: {
            address1: response.address.address1,
            city: response.address.city,
            country: response.address.country,
            phoneNumber: response.address.phone
        }
    };

    FedexResponse targetType = check fedEx->/api/en\-us/catalog/ship/v1/shipments.post(fedexReq);
    return targetType;
}

function creeateDhlShipment(OrderResponse response) returns DHLResponse|error {
    ShipmentRequest dhlReq = {
        amount: response.total,
        currency: response.currency,
        personName: response.address.fullName,
        email: response.email,
        address: {
            name: response.address.fullName,
            address1: response.address.address1,
            city: response.address.city,
            country: response.address.country,
            phoneNumber: response.address.phone
        }
    };

    DHLResponse targetType = check dhlExpress->/mydhlapi/shipments.post(dhlReq);
    return targetType;
}

function sendConfirmationMail(string name, string email, string trackingNumber) returns error? {
    string body = string `<p>Hello ${name}!</p><p>Your Order has been shipped. ` +
                string `Track your order using ${trackingNumber}</p>`;
    var mailReq = {
        toInfo: email,
        fromInfo: "orders@blackwell.com",
        subject: "Order Confirmation",
        content: body
    };

    json jsonResult = check sendgrid->/v3/mail/send.post(mailReq, targetType = json);
}
