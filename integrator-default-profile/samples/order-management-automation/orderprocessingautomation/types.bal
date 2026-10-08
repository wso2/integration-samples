import ballerina/time;

public type PlacedOrdersType record {|
    string orderId;
    decimal amount;
    string status;
    time:Civil placedAt;
    string customerId;
    string productId;
    PlacedOrdersCustomerType customer;
    PlacedOrdersProductType product;
|};

public type PlacedOrdersCustomerType record {|
    string customerId;
    string name;
    string email;
    string address;
|};

public type PlacedOrdersProductType record {|
    string productId;
    string productName;
    string category;
    decimal price;
|};
