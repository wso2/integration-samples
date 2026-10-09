public type OrderEvent record {|
    string orderId;
    string customerId;
    decimal amount;
    string timestamp;
|};
