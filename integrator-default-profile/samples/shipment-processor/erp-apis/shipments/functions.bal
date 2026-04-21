import ballerina/sql;
import ballerina/time;

// Function to get distinct shipment IDs from database 
public function getDistinctShipmentIds() returns string[]|error {
    sql:ParameterizedQuery query = `SELECT DISTINCT shipment_id FROM shipment_products`;
    stream<ShipmentIdRecord, sql:Error?> resultStream = dbClient->query(query);

    string[] shipmentIds = [];
    check from ShipmentIdRecord shipmentRecord in resultStream
        do {
            shipmentIds.push(shipmentRecord.shipment_id);
        };

    check resultStream.close();
    return shipmentIds;
}

// Function to update shipment status in database
public function updateShipmentStatusInDb(string shipmentId, ShipmentStatus status, string? actualDeliveryDate) returns error? {
    sql:ParameterizedQuery updateQuery;

    if actualDeliveryDate is string {
        updateQuery = `UPDATE shipment_products SET status = ${status.toString()}, actual_delivery_date = ${actualDeliveryDate} WHERE shipment_id = ${shipmentId}`;
    } else {
        updateQuery = `UPDATE shipment_products SET status = ${status.toString()} WHERE shipment_id = ${shipmentId}`;
    }

    sql:ExecutionResult result = check dbClient->execute(updateQuery);

    if result.affectedRowCount == 0 {
        return error("Shipment not found in database");
    }
}

// Function to get current date in YYYY-MM-DD format
public function getCurrentDate() returns string {
    time:Utc currentUtc = time:utcNow();
    time:Civil currentCivil = time:utcToCivil(currentUtc);
    return string `${currentCivil.year}-${currentCivil.month.toString().padZero(2)}-${currentCivil.day.toString().padZero(2)}`;
}

// Function to get NDJSON content by file name
public function getNdjsonContentByFileName(string fileName) returns NdjsonLogRecord[]|error {
    sql:ParameterizedQuery query = `SELECT id, file_name, ndjson_content, record_count, content_size, processed_at, sftp_uploaded, sftp_path, created_at, updated_at, batch_no FROM ndjson_logs WHERE file_name = ${fileName}`;
    stream<NdjsonLogRecord, sql:Error?> resultStream = dbClient->query(query);

    NdjsonLogRecord[] ndjsonLogs = [];
    check from NdjsonLogRecord logRecord in resultStream
        do {
            ndjsonLogs.push(logRecord);
        };

    check resultStream.close();
    return ndjsonLogs;
}

// Function to get only NDJSON content (string) by ID
public function getNdjsonContentStringById(int logId) returns string|error {
    sql:ParameterizedQuery query = `SELECT ndjson_content FROM ndjson_logs WHERE id = ${logId}`;
    record {|string ndjson_content;|} result = check dbClient->queryRow(query);
    return result.ndjson_content;
}
