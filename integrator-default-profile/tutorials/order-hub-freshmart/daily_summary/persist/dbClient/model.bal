import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

@sql:Name {value: "orders"}
public type Order record {|
    @sql:Generated
    readonly int id;
    @sql:Name {value: "order_id"}
    @sql:Varchar {length: 64}
    @sql:UniqueIndex {name: "order_id"}
    string orderId;
    @sql:Name {value: "supplier_code"}
    @sql:Varchar {length: 32}
    @sql:UniqueIndex {name: "order_id"}
    string supplierCode;
    @sql:Name {value: "order_date"}
    time:Date orderDate;
    @sql:Name {value: "order_total"}
    @sql:Decimal {precision: [12, 2]}
    decimal orderTotal;
    @sql:Varchar {length: 8}
    string currency;
    OrderLine[] orderlines;
|};

@sql:Name {value: "order_lines"}
public type OrderLine record {|
    @sql:Generated
    readonly int id;
    @sql:Varchar {length: 64}
    string sku;
    @sql:Varchar {length: 255}
    string? description;
    int quantity;
    @sql:Name {value: "unit_price"}
    @sql:Decimal {precision: [12, 2]}
    decimal unitPrice;
    @sql:Name {value: "line_total"}
    @sql:Decimal {precision: [12, 2]}
    decimal lineTotal;
    @sql:Name {value: "order_id"}
    @sql:Index {name: "order_id"}
    int orderId;
    @sql:Relation {keys: ["orderId"]}
    Order 'order;
|};
