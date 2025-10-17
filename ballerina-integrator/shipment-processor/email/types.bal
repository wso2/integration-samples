// Shipment related types
public type ShipmentPayload record {
    string customerId;
    string shipmentId;
    string shipmentDate;
    Product[] products;
};

public type Product record {
    string productCode;
    int qty;
};

// Kafka message type
public type ShipmentMessage record {
    string customerId;
    string customerName;
    string customerEmail;
    string shipmentId;
    string shipmentDate;
    Product[] products;
    string status;
    string timestamp;
};