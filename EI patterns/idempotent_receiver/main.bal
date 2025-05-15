import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    resource function put manage\-orders/[string orderId](OrderDetail orderDetail) returns http:STATUS_NO_CONTENT|http:STATUS_CREATED {
        map<OrderStatus> orderStatuses = {};
        "CANCELLED"|"COMPLETED"|"SHIPPED"|"CREATED"|() orderStatus = orderStatuses[orderId];
        if orderStatus == orderDetail.status {
            return http:STATUS_NO_CONTENT;
        } else {
            orderStatuses[orderId] = orderDetail.status;
            return http:STATUS_CREATED;
        }
    }
}
