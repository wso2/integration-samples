import ballerina/sql;

type Pizza record {|
    string id;
    string name;
    string description;
    @sql:Column {
        name: "base_price"
    }
    decimal basePrice;
    json toppings;
|};

type OrderPizza record {|
    @sql:Column {
        name: "pizza_id"
    }
    string pizzaId;
    int quantity;
    json customizations;
|};

type OrderRequest record {|
    string customerId;
    OrderPizza[] pizzas;
|};

enum OrderStatus {
    PENDING,
    PREPARING,
    OUT_FOR_DELIVERY,
    DELIVERED,
    CANCELLED
}

type Order record {|
    string id;
    @sql:Column {
        name: "customer_id"
    }
    string customerId;
    OrderStatus status;
    @sql:Column {
        name: "total_price"
    }
    decimal totalPrice;
    OrderPizza[] pizzas;
|};

type OrderUpdate record {|
    OrderStatus status;
|};
