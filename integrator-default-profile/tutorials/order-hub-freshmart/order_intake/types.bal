import ballerina/data.xmldata;

public type OrderLine record {|
    string sku;
    string description;
    int quantity;
    decimal unitPrice;
    decimal lineTotal;
|};

public type Order record {|
    string orderId;
    string supplierCode;
    string orderDate;
    OrderLine[] lines;
    decimal orderTotal;
    string currency;
|};

type GreenfieldRow record {|
    string order_id;
    string order_date;
    string sku;
    string description;
    int qty;
    decimal unit_price;
|};

type Item record {
    @xmldata:Attribute
    string code;
    @xmldata:Attribute
    string name;
    @xmldata:Attribute
    string price;
    @xmldata:Attribute
    string units;
};

type Items record {
    Item[] item;
};

@xmldata:Name {
    value: "purchaseOrder"
}
type HarborOrder record {
    Items items;
    @xmldata:Attribute
    string currency;
    @xmldata:Attribute
    string date;
    @xmldata:Attribute
    string id;
};
