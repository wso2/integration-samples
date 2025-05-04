import ballerina/http;

function checkout(Message message, Points points) returns PaymentStatus {
    float totalPoints = points.loyaltyPoints + points.mobilePoints;
    return {
        status: "SUCCESS",
        details: {
            totalPoints: totalPoints,
            redeemedAmount: totalPoints * 50,
            totalAmount: message.totalAmount - (totalPoints * 50)
        }
    };
}

function lookupMessageSlip(PaymentRequest request) returns string[]|error {
    final http:Client openLoyalty = check new ("http://openloyalty.com.balmock.io");
    anydata|error customer = openLoyalty->/api/[request.storeCode]/member/'check/get.get();
    string[] routingSlip = [];
    if customer is anydata {
        () var1 = routingSlip.push("CustomerLoyaltyPoints");
    }
    if check isRegisteredToPointsService(request.mobileNumber) {
        () var1 = routingSlip.push("MobilePoints");
    }
    return routingSlip;
}

function isRegisteredToPointsService(string mobileNumber) returns boolean|error {
    http:Client openLoyalty = check new ("http://mob.points.hub.com.balmock.io");
    anydata|error memberCheck = openLoyalty->/api/[mobileNumber]/member/'check/get();
    return memberCheck is error ? false : true;
}
