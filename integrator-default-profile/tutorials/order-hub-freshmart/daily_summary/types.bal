import ballerina/time;

public type OrderSummaryType record {|
    string orderId;
    string supplierCode;
    time:Date orderDate;
    decimal orderTotal;
    string currency;
|};
