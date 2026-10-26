import ballerina/log;

public function main() returns error? {
    do {
        string result = check rudderstackClient->track({userId: "u-1001", event: "Order Completed", properties: {"orderId": "o-5001", "revenue": 89.99, "currency": "USD"}});
        log:printInfo(result);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
