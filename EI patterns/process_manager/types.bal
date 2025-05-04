type OrderRequest record {|
    string email;
    Address address;
    OrderItemRequest[] orderItems;
|};

type OrderResponse record {|
    string email;
    string currency;
    float total;
    Address address;
    OrderItemResponse[] orderItems;
    string trackingNumber;
|};

type Address record {|
    string fullName;
    string address1;
    string phone;
    string city;
    string country;
|};

type OrderItemRequest record {
    string itemName;
    int quantity;
};

type OrderItemResponse record {|
    string itemName;
    int quantity;
    float price;
    string currencyCode;
|};

type ShipmentRequest record {|
    float amount;
    string currency;
    string personName;
    string email;
    DHLAddress|FedexAddress address;
|};

type FedexAddress record {|
    string address1;
    string city;
    string country;
    string phoneNumber;
|};

type DHLAddress record {|
    string name;
    string address1;
    string city;
    string country;
    string phoneNumber;
|};

type FedexResponse record {|
    string transactionId;
    string trackingNumber;
|};

type DHLResponse record {|
    string trackingNumber;
|};
