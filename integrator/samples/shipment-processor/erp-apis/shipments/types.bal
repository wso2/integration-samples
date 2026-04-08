// Product record type
public type Product record {|
    string productCode;
    int qty;
|};

// Shipment status enumeration
public enum ShipmentStatus {
    PENDING,
    PROCESSING,
    IN_TRANSIT,
    OUT_FOR_DELIVERY,
    DELIVERED,
    CANCELLED,
    RETURNED
}

// Comprehensive shipment record type
public type Shipment record {|
    string shipmentId;
    string orderId;
    string customerId;
    string customerName;
    string origin;
    string destination;
    ShipmentStatus status;
    string createdDate;
    string? estimatedDeliveryDate;
    string? actualDeliveryDate;
    decimal totalWeight;
    string carrier;
    string trackingNumber;
    Product[] products;
|};

public type ShipmentNotFound record {|
    string message;
    string shipmentId;
|};

// Record type for database query result
public type ShipmentIdRecord record {|
    string shipment_id;
|};

// Response type for distinct shipment IDs
public type DistinctShipmentIdsResponse record {|
    string[] shipmentIds;
    int count;
|};

// Request type for updating shipment status
public type ShipmentStatusUpdateRequest record {|
    ShipmentStatus shipmentStatus;
|};

// Response type for successful shipment update
public type ShipmentUpdateResponse record {|
    string message;
    string shipmentId;
    ShipmentStatus updatedStatus;
    string? actualDeliveryDate;
|};

// Response type for update errors
public type ShipmentUpdateError record {|
    string message;
    string shipmentId;
    string errorCode;
|};

// Invoice item record type
public type InvoiceItem record {|
    string productCode;
    string productName;
    int quantity;
    decimal unitPrice;
    decimal totalPrice;
|};

// Invoice record type
public type Invoice record {|
    string invoiceId;
    string customerId;
    string customerName;
    string customerEmail;
    string invoiceDate;
    string? dueDate;
    InvoiceItem[] items;
    decimal subtotal;
    decimal taxAmount;
    decimal totalAmount;
    string currency;
    string status;
    string? shipmentId;
|};

// Request type for publishing invoice
public type InvoicePublishRequest record {|
    string customerId;
    string customerName;
    string customerEmail;
    string? dueDate;
    InvoiceItem[] items;
    decimal taxAmount;
    string currency;
    string? shipmentId;
|};

// Response type for successful invoice publication
public type InvoicePublishResponse record {|
    string message;
    string invoiceId;
    string customerId;
    decimal totalAmount;
    string invoiceDate;
|};

// Response type for invoice publication errors
public type InvoicePublishError record {|
    string message;
    string errorCode;
    string details;
|};

// NDJSON logs table record type
public type NdjsonLogRecord record {|
    int id;
    string file_name;
    string ndjson_content;
    int record_count;
    int content_size;
    string? processed_at;
    boolean sftp_uploaded;
    string? sftp_path;
    string created_at;
    string updated_at;
    string? batch_no;
|};

// Response type for NDJSON content retrieval
public type NdjsonContentResponse record {|
    int id;
    string fileName;
    string ndjsonContent;
    int recordCount;
    int contentSize;
    string? batchNo;
|};

// Response type for all NDJSON logs
public type NdjsonLogsResponse record {|
    NdjsonLogRecord[] logs;
    int count;
|};