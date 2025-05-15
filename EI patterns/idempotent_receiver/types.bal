type OrderDetail record {
    string orderId;
    OrderStatus status;
};

enum OrderStatus {
    CREATED,
    SHIPPED,
    COMPLETED,
    CANCELLED
}
