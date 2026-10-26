import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

@sql:Name {value: "orders"}
public type Order record {|
    @sql:Generated
    readonly int id;
    @sql:Index {name: "idx_orders_customer_id"}
    int customerId;
    @sql:Varchar {length: 20}
    string status;
    @sql:Decimal {precision: [10, 2]}
    decimal total;
    time:Utc createdAt;
    OrderItem[] orderitems;
    @sql:Relation {keys: ["customerId"]}
    Customer customer;
|};

@sql:Name {value: "customers"}
public type Customer record {|
    @sql:Generated
    readonly int id;
    @sql:Varchar {length: 120}
    string name;
    @sql:Varchar {length: 160}
    @sql:UniqueIndex {name: "customers_email_key"}
    string email;
    time:Utc createdAt;
    Order[] orders;
|};

@sql:Name {value: "order_items"}
public type OrderItem record {|
    @sql:Generated
    readonly int id;
    @sql:Index {name: "idx_order_items_order_id"}
    int orderId;
    int productId;
    int quantity;
    @sql:Decimal {precision: [10, 2]}
    decimal unitPrice;
    @sql:Relation {keys: ["orderId"]}
    Order 'order;
    @sql:Relation {keys: ["productId"]}
    Product product;
|};

@sql:Name {value: "products"}
public type Product record {|
    @sql:Generated
    readonly int id;
    @sql:Varchar {length: 60}
    @sql:UniqueIndex {name: "products_sku_key"}
    string sku;
    @sql:Varchar {length: 160}
    string name;
    @sql:Decimal {precision: [10, 2]}
    decimal price;
    int stock;
    OrderItem[] orderitems;
|};
