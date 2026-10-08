import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

@sql:Name {value: "orders"}
public type Order record {|
    @sql:Name {value: "order_id"}
    @sql:Varchar {length: 36}
    readonly string orderId;
    @sql:Name {value: "customer_id"}
    @sql:Varchar {length: 36}
    @sql:Index {name: "customer_id"}
    string customerId;
    @sql:Name {value: "product_id"}
    @sql:Varchar {length: 36}
    @sql:Index {name: "product_id"}
    string productId;
    @sql:Decimal {precision: [10, 2]}
    decimal amount;
    @sql:Varchar {length: 20}
    string status;
    @sql:Name {value: "placed_at"}
    time:Civil placedAt;
    @sql:Relation {keys: ["customerId"]}
    Customer customer;
    @sql:Relation {keys: ["productId"]}
    Product product;
|};

@sql:Name {value: "customers"}
public type Customer record {|
    @sql:Name {value: "customer_id"}
    @sql:Varchar {length: 36}
    readonly string customerId;
    @sql:Varchar {length: 100}
    string name;
    @sql:Varchar {length: 100}
    string email;
    @sql:Varchar {length: 255}
    string address;
    Order[] orders;
|};

@sql:Name {value: "products"}
public type Product record {|
    @sql:Name {value: "product_id"}
    @sql:Varchar {length: 36}
    readonly string productId;
    @sql:Name {value: "product_name"}
    @sql:Varchar {length: 100}
    string productName;
    @sql:Varchar {length: 50}
    string category;
    @sql:Decimal {precision: [10, 2]}
    decimal price;
    Order[] orders;
|};
