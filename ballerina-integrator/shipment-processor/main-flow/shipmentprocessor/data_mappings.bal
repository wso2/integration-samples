// Data mapping functions for shipment processing

// Map CSV record to API request format
public function mapCsvToShipmentRequest(ShipmentCsvRecord csvRecord) returns map<string> {
    map<string> requestData = {
        "shipmentId": csvRecord.shipmentId,
        "shipmentDate": csvRecord.shipmentDate,
        "productCode": csvRecord.productCode,
        "email": csvRecord.email,
        "status": csvRecord.shipmentStatus
    };

    string? orderId = csvRecord.orderId;
    if orderId is string {
        requestData["orderId"] = orderId;
    }

    string? origin = csvRecord.origin;
    if origin is string {
        requestData["origin"] = origin;
    }

    string? destination = csvRecord.destination;
    if destination is string {
        requestData["destination"] = destination;
    }

    return requestData;
}

// Data Mapper 
public function enrichShipmentWithCsvData(Shipment apiResponse, ShipmentCsvRecord csvRecord, CorrelationId correlationId) returns EnrichedShipment {
    // Direct field mapping 
    EnrichedShipment enrichedShipment = {
        // Core identifiers
        shipmentId: apiResponse.shipmentId,
        correlationId: correlationId,

        // CSV-specific fields (enrichment data)
        shipmentDate: csvRecord.shipmentDate,
        csvProductCode: csvRecord.productCode,
        customerEmail: csvRecord.email,

        // API response fields (direct mapping)
        orderId: apiResponse.orderId,
        customerId: apiResponse.customerId,
        customerName: apiResponse.customerName,
        origin: apiResponse.origin,
        destination: apiResponse.destination,
        status: apiResponse.status,
        createdDate: apiResponse.createdDate,
        estimatedDeliveryDate: apiResponse.estimatedDeliveryDate,
        actualDeliveryDate: apiResponse.actualDeliveryDate,
        totalWeight: apiResponse.totalWeight,
        carrier: apiResponse.carrier,
        trackingNumber: apiResponse.trackingNumber,
        products: apiResponse.products
    };

    return enrichedShipment;
}

// NDJSON conversion function - generates newline-delimited JSON using built-in toJsonString()
public function convertToNdjson(EnrichedShipment[] enrichedShipments) returns string {
    string[] ndjsonLines = [];

    foreach EnrichedShipment enrichedShipment in enrichedShipments {
        // Use Ballerina's built-in JSON conversion for cleaner, more reliable output
        string jsonLine = enrichedShipment.toJsonString();
        ndjsonLines.push(jsonLine);
    }

    // Join all JSON lines with newlines to create NDJSON format
    return string:'join("\n", ...ndjsonLines) + (ndjsonLines.length() > 0 ? "\n" : "");
}


