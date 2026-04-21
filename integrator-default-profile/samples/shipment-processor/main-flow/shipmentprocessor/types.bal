// Correlation ID type
public type CorrelationId string;

// Shipment status enumeration
public enum ShipmentStatus {
    PENDING = "PENDING",
    IN_TRANSIT = "IN_TRANSIT",
    DELIVERED = "DELIVERED",
    CANCELLED = "CANCELLED",
    PROCESSING = "PROCESSING",
    RETURNED = "RETURNED"   
}

// Product record type for shipment products
public type Product record {|
    string productCode;
    int qty;
|};

// Shipment record type
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
    Product[] products; // Added products array
|};

// Enriched shipment record type with CSV data
public type EnrichedShipment record {|
    string shipmentId;
    string shipmentDate; // Added from CSV
    string csvProductCode; // Added CSV product code
    string customerEmail; // Added email from CSV
    CorrelationId correlationId;
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
    Product[] products; // Added products array
|};

// Database record type for shipment_products table
public type ShipmentProduct record {|
    string shipment_id;
    string shipment_date;
    string csv_product_code; // Added CSV product code field
    string customer_email; // Added customer email field
    string correlation_id;
    string order_id;
    string customer_id;
    string customer_name;
    string origin;
    string destination;
    string status;
    string created_date;
    string? estimated_delivery_date;
    string? actual_delivery_date;
    decimal total_weight;
    string carrier;
    string tracking_number;
    string processed_at; // Timestamp when record was processed
    string products_json; // Added to store products as JSON string
|};

// Database record type for ndjson_logs table
public type NdjsonLogRecord record {|
    string fileName;
    int batchNo;
    string ndjsonContent;
    CorrelationId correlationId;
    int recordCount;
    int contentSize;
    string processedAt;
    boolean sftpUploaded;
    string? sftpPath;
|};

// Request body for updating shipment
public type ShipmentUpdateRequest record {|
    ShipmentStatus status;
    string? estimatedDeliveryDate?;
    string? actualDeliveryDate?;
|};

// Error response type
public type ErrorResponse record {|
    string message;
    string code;
|};

// CSV record type for shipment data
public type ShipmentCsvRecord record {|
    string shipmentId;
    string shipmentDate;
    string productCode;
    string email;
    string shipmentStatus;
    string? orderId;
    string? origin;
    string? destination;
|};

// Processing result type with enriched data and NDJSON output
public type ProcessingResult record {|
    int totalRecords;
    int successfulRecords;
    int failedRecords;
    int quarantinedRecords;
    string[] errors;
    EnrichedShipment[] enrichedShipments; // Added to store enriched data
    string[] ndjsonFiles; // Added to track generated NDJSON files
    int dbInsertedRecords; // Added to track database insertions
    string[] sftpUploadedFiles; // Added to track SFTP uploaded files
|};

// Quarantine record type
public type QuarantineRecord record {|
    string[] csvRow;
    string errorMessage;
    string timestamp;
    int attemptCount;
|};

// Enhanced quarantine database record type
public type QuarantineDbRecord record {|
    string quarantine_id;           // Auto-generated unique ID
    string shipment_id;             // Original shipment ID from CSV
    string shipment_date;           // Shipment date from CSV
    string csv_product_code;        // Product code from CSV
    string email;                   // Email from CSV
    string shipment_status;         // Status from CSV
    string? order_id;               // Optional order ID
    string? origin;                 // Optional origin
    string? destination;            // Optional destination
    string correlation_id;          // Processing correlation ID
    string error_message;           // Error that caused quarantine
    string error_type;              // Classification of error (API_ERROR, VALIDATION_ERROR, etc.)
    int attempt_count;              // Number of retry attempts made
    string quarantined_at;          // Timestamp when quarantined
    string csv_row_json;            // Full CSV row as JSON for complete record
    string file_name;               // Source file name
    string file_source;             // FTP or LOCAL
    boolean retry_eligible;         // Whether this record can be retried
    string? retry_after;            // Optional timestamp for when retry should be attempted
    string? resolved_at;            // Timestamp when resolved (if applicable)
    string? resolution_notes;       // Notes about resolution
|};

// File source enumeration
public enum FileSource {
    FTP = "FTP",
    LOCAL = "LOCAL"
}

// File processing context
public type FileProcessingContext record {|
    string fileName;
    FileSource 'source;
    string fullPath;
    int fileSize?;
    CorrelationId correlationId;
|};

// NDJSON processing result
public type NdjsonResult record {|
    string fileName;
    string filePath;
    int recordCount;
    int fileSize;
    boolean success;
    string? errorMessage;
    boolean sftpUploaded; // Added to track SFTP upload status
    string? sftpPath; // Added to track SFTP upload path
|};

// Database operation result
public type DatabaseResult record {|
    boolean success;
    int recordsInserted;
    string? errorMessage;
|};

// Line processing result for batched stream processing
public type LineProcessingResult record {|
    string[] completeLines;
    string remainingBuffer;
|};

// Stream processing statistics
public type StreamProcessingStats record {|
    int totalBatches;
    int totalBytesProcessed;
    int totalLinesProcessed;
    int processingTimeMs;
    boolean memoryOptimized;
|};

// Shipment message type to be sent to kakfa topic
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
