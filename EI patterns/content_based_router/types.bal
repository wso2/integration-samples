type DhlUkResponse record {|
    string url;
    ShipmentData[] shipments;
|};

type ShipmentData record {|
    string id;
    Status status;
|};

type DhlDpiResponse record {|
    Status[] events;
    string publicUrl;
    string barcode;
|};

type Status record {|
    string statusCode;
    string status;
|};

enum Country {
    UK,
    DE
}
