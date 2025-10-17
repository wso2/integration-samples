# DEMO
<img width="1115" height="635" alt="image" src="https://github.com/user-attachments/assets/4be8f2c0-9ea7-44af-8a50-18155720e6f9" />


**Flow - Diagram**
<img width="1434" height="613" alt="image" src="https://github.com/user-attachments/assets/4ac345c7-4299-4c3f-af0e-2789de7f8120" />

**README – File Processing Steps**
1. Add the shared CSV files(/data) to one of the following directories:

   /csv/dev

   /csv/prod

2. The file will automatically start processing.

3. Once processing is complete, the corresponding file will be moved to:

   /processed/dev

   /processed/prod

4. Shipment product details will be inserted into the shipment_products table.


5. NDJSON logs will be recorded in the ndjson_logs table.

6. You can view the results Bijira console
 Go to [https://console.bijira.](https://devportal.bijira.dev/)
 
Click Generate URL
 
 <img width="750" height="242" alt="image" src="https://github.com/user-attachments/assets/978ef99e-c68b-40a6-8711-62a6b29be5ba" />
 Try out 
 <img width="1349" height="233" alt="image" src="https://github.com/user-attachments/assets/9d42cdfd-3b36-4ffa-863a-2837247bf01d" />


<img width="1301" height="612" alt="image" src="https://github.com/user-attachments/assets/68ce7528-a424-4015-97b0-faa74ab66e38" />


7. Any quarantine records will be added to the quarantine_records table.


   
8. Email will be sent for each shipoments 
<img width="852" height="403" alt="image" src="https://github.com/user-attachments/assets/24e11b4b-3b06-4262-b9a2-6db215bf0f85" />

9. Generate customer-wise PDF reports
   /reports

10. Generate Invoices : Go to /invoices and try out by adding below payload

{
    "customerId": "CUST001",
    "customerName": "John Smith",
    "customerEmail": "john.smith@email.com",
    "dueDate": "2024-02-15",
    "items": [
      {
        "productCode": "XY123",
        "productName": "Laptop Computer",
        "quantity": 2,
        "unitPrice": 999.99,
        "totalPrice": 1999.98
      },
      {
        "productCode": "AB456",
        "productName": "Wireless Mouse",
        "quantity": 2,
        "unitPrice": 29.99,
        "totalPrice": 59.98
      }
    ],
    "taxAmount": 205.99,
    "currency": "USD",
    "shipmentId": "SH001"
  }
<img width="1281" height="277" alt="image" src="https://github.com/user-attachments/assets/5746696b-f9ce-472e-a23c-5e628023dae5" />

<img width="1281" height="537" alt="image" src="https://github.com/user-attachments/assets/3d46fc25-becf-46cd-afe3-02c76571ab06" />

11. You may execute /shipments/{shipment_id} to get shipment details
    <img width="1281" height="560" alt="image" src="https://github.com/user-attachments/assets/892dcd77-017f-4273-986e-4f9cb3d90cc2" />
    <img width="1281" height="560" alt="image" src="https://github.com/user-attachments/assets/7aadec32-583c-4ece-a48c-1eacff0118a1" />




13. You may execute /shipments/ids to get distinct shipment ids
<img width="1281" height="537" alt="image" src="https://github.com/user-attachments/assets/c359482b-b945-4b6a-ab25-202f1b59ab6f" />
<img width="1281" height="537" alt="image" src="https://github.com/user-attachments/assets/6e898cc9-e134-4c56-83f7-42c248064069" />


14. You can observe logs under Observability section

2025-10-16T16:22:47.642Z Application Logs v1.0 Production INFO Downloading file 250915_2k_shipments.csv to /tmp/file_processing/250915_2k_shipments.csv_proc {"module":"shashika/shipmentprocessor","correlationId":"4262b622-8052-4b7f-9a20-622136db152a"}
2025-10-16T16:22:49.968Z Application Logs v1.0 Production INFO Successfully downloaded and saved 250915_2k_shipments.csv as /tmp/file_processing/250915_2k_shipments.csv_proc {"module":"shashika/shipmentprocessor","correlationId":"4262b622-8052-4b7f-9a20-622136db152a"}
2025-10-16T16:22:49.969Z Application Logs v1.0 Production INFO Processing CSV file: 250915_2k_shipments.csv {"module":"shashika/shipmentprocessor","correlationId":"4262b622-8052-4b7f-9a20-622136db152a"}
2025-10-16T16:23:17.629Z Application Logs v1.0 Production INFO File already exists in temp directory: /tmp/file_processing/250915_2k_shipments.csv_proc {"module":"shashika/shipmentprocessor","correlationId":"71f05a02-46ce-46fe-bd66-1e6bbf1a84d6"}
2025-10-16T16:23:17.630Z Application Logs v1.0 Production INFO Processing CSV file: 250915_2k_shipments.csv {"module":"shashika/shipmentprocessor","correlationId":"71f05a02-46ce-46fe-bd66-1e6bbf1a84d6"}
2025-10-16T16:23:17.695Z Application Logs v1.0 Production INFO Enriched shipment: {shipmentId: "SH001", orderId: "ORD001", customerId: "CUST001", customerName: "Sarah Brown", status: PENDING} {"module":"shashika/shipmentprocessor","correlationId":"1ded4bfc-fad9-44f5-ac81-bbe4a2dad4df"}
2025-10-16T16:23:17.713Z Application Logs v1.0 Production INFO Enriched shipment: {shipmentId: "SH001", orderId: "ORD001", customerId: "CUST001", customerName: "Sarah Brown", status: PENDING} {"module":"shashika/shipmentprocessor","correlationId":"6e59d19d-9381-48f4-876f-bcc65f91d748"}

2025-10-16T16:27:54.018Z Application Logs v1.0 Production INFO Processed 1000/1000 records in batch {"module":"shashika/shipmentprocessor","correlationId":"ea532551-450a-49d4-959c-0fc364cce0d9"}
2025-10-16T16:27:54.018Z Application Logs v1.0 Production INFO Starting async batch insert of 1000 enriched shipments {"module":"shashika/shipmentprocessor"}
2025-10-16T16:27:54.023Z Application Logs v1.0 Production INFO Database batch progress: 1000/1000 records processed {"module":"shashika/shipmentprocessor"}
2025-10-16T16:27:54.023Z Application Logs v1.0 Production INFO Batch insert completed: 1000 records inserted, 0 errors {"module":"shashika/shipmentprocessor"}
2025-10-16T16:27:54.073Z Application Logs v1.0 Production INFO CSV file processing completed - no more data rows {"module":"shashika/shipmentprocessor","correlationId":"ea532551-450a-49d4-959c-0fc364cce0d9"}

2025-10-16T16:27:58.255Z Application Logs v1.0 Production INFO CSV processing completed: 250915_2k_shipments.csv, batches: 3, total: 2025 {"module":"shashika/shipmentprocessor","correlationId":"ea532551-450a-49d4-959c-0fc364cce0d9"}
2025-10-16T16:27:58.258Z Application Logs v1.0 Production INFO File processing completed: 250915_2k_shipments.csv, total: 2025, successful: 2025, failed: 0, quarantined: 0, enriched: 2025, ndjson files: 3, db inserted: 2025 {"module":"shashika/shipmentprocessor","correlationId":"ea532551-450a-49d4-959c-0fc364cce0d9"}


