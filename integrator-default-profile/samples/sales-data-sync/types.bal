
type ItemsItem record {|
    string itemId;
    int quantity;
    decimal totalAmount;
|};

type Items ItemsItem[];

type SalesReport record {|
    string storeId;
    string storeLocation;
    string saleDate;
    Items items;
|};
