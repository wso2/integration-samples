import ballerina/http;

// Sample data arrays for generating mock shipments
string[] sampleCities = [
    "New York, NY",
    "Los Angeles, CA",
    "Chicago, IL",
    "Houston, TX",
    "Phoenix, AZ",
    "Philadelphia, PA",
    "San Antonio, TX",
    "San Diego, CA",
    "Dallas, TX",
    "San Jose, CA",
    "Austin, TX",
    "Jacksonville, FL",
    "Fort Worth, TX",
    "Columbus, OH",
    "Charlotte, NC",
    "San Francisco, CA",
    "Indianapolis, IN",
    "Seattle, WA",
    "Denver, CO",
    "Washington, DC",
    "Boston, MA",
    "El Paso, TX",
    "Nashville, TN",
    "Detroit, MI",
    "Oklahoma City, OK",
    "Portland, OR",
    "Las Vegas, NV",
    "Memphis, TN",
    "Louisville, KY",
    "Baltimore, MD",
    "Milwaukee, WI",
    "Albuquerque, NM",
    "Tucson, AZ",
    "Fresno, CA",
    "Sacramento, CA",
    "Mesa, AZ",
    "Kansas City, MO",
    "Atlanta, GA",
    "Long Beach, CA",
    "Colorado Springs, CO",
    "Raleigh, NC",
    "Miami, FL",
    "Virginia Beach, VA",
    "Omaha, NE",
    "Oakland, CA",
    "Minneapolis, MN",
    "Tulsa, OK",
    "Arlington, TX",
    "Tampa, FL",
    "New Orleans, LA"
];

string[] sampleFirstNames = [
    "John",
    "Sarah",
    "Michael",
    "Emily",
    "Robert",
    "Jessica",
    "William",
    "Ashley",
    "David",
    "Amanda",
    "James",
    "Jennifer",
    "Christopher",
    "Lisa",
    "Matthew",
    "Michelle",
    "Anthony",
    "Kimberly",
    "Mark",
    "Amy",
    "Donald",
    "Angela",
    "Steven",
    "Helen",
    "Paul",
    "Anna",
    "Andrew",
    "Brenda",
    "Joshua",
    "Emma",
    "Kenneth",
    "Olivia",
    "Kevin",
    "Cynthia",
    "Brian",
    "Marie",
    "George",
    "Janet",
    "Timothy",
    "Catherine",
    "Ronald",
    "Frances",
    "Jason",
    "Samantha",
    "Edward",
    "Deborah",
    "Jeffrey",
    "Rachel",
    "Ryan",
    "Carolyn"
];

string[] sampleLastNames = [
    "Smith",
    "Johnson",
    "Williams",
    "Brown",
    "Jones",
    "Garcia",
    "Miller",
    "Davis",
    "Rodriguez",
    "Martinez",
    "Hernandez",
    "Lopez",
    "Gonzalez",
    "Wilson",
    "Anderson",
    "Thomas",
    "Taylor",
    "Moore",
    "Jackson",
    "Martin",
    "Lee",
    "Perez",
    "Thompson",
    "White",
    "Harris",
    "Sanchez",
    "Clark",
    "Ramirez",
    "Lewis",
    "Robinson",
    "Walker",
    "Young",
    "Allen",
    "King",
    "Wright",
    "Scott",
    "Torres",
    "Nguyen",
    "Hill",
    "Flores",
    "Green",
    "Adams",
    "Nelson",
    "Baker",
    "Hall",
    "Rivera",
    "Campbell",
    "Mitchell",
    "Carter",
    "Roberts"
];

string[] sampleCarriers = [
    "Express Logistics",
    "Fast Ship Co",
    "Reliable Transport",
    "Quick Delivery",
    "Standard Shipping",
    "Prime Express",
    "Global Freight",
    "Swift Cargo",
    "Rapid Transit",
    "Elite Shipping",
    "Metro Logistics",
    "Coast to Coast",
    "National Express",
    "Direct Transport",
    "Speed Delivery"
];

string[] sampleProductCodes = [
    "XY123",
    "AB456",
    "CD789",
    "EF012",
    "GH345",
    "IJ678",
    "KL901",
    "MN234",
    "OP567",
    "QR890",
    "ST123",
    "UV456",
    "WX789",
    "YZ012",
    "AA345",
    "BB678",
    "CC901",
    "DD234",
    "EE567",
    "FF890",
    "GG123",
    "HH456",
    "II789",
    "JJ012",
    "KK345",
    "LL678",
    "MM901",
    "NN234",
    "OO567",
    "PP890",
    "QQ123",
    "RR456",
    "SS789",
    "TT012",
    "UU345",
    "VV678",
    "WW901",
    "XX234",
    "YY567",
    "ZZ890"
];

ShipmentStatus[] sampleStatuses = [PENDING, PROCESSING, IN_TRANSIT, OUT_FOR_DELIVERY, DELIVERED, CANCELLED, RETURNED];

// In-memory storage for invoices
map<Invoice> publishedInvoices = {};
int invoiceCounter = 1;

// Function to generate mock shipments from SH001 to SH100 with multiple shipments per customer
function generateMockShipments() returns map<Shipment> {
    map<Shipment> shipments = {};

    // Create fewer unique customers so multiple shipments belong to same customer
    int totalCustomers = 35; // This will create ~2-3 shipments per customer on average

    int i = 1;
    while i <= 100 {
        string shipmentId = string `SH${i.toString().padZero(3)}`;
        string orderId = string `ORD${i.toString().padZero(3)}`;
        
        // Use modulo to assign multiple shipments to same customer
        int customerIndex = (i - 1) % totalCustomers + 1;
        string customerId = string `CUST${customerIndex.toString().padZero(3)}`;

        // Generate consistent customer name for the same customer ID
        string firstName = sampleFirstNames[customerIndex % sampleFirstNames.length()];
        string lastName = sampleLastNames[(customerIndex * 3) % sampleLastNames.length()];
        string customerName = string `${firstName} ${lastName}`;

        // Generate origin and destination
        string origin = sampleCities[i % sampleCities.length()];
        string destination = sampleCities[(i * 7) % sampleCities.length()];

        // Ensure origin and destination are different
        if origin == destination {
            destination = sampleCities[(i * 7 + 1) % sampleCities.length()];
        }

        // Generate status
        ShipmentStatus status = sampleStatuses[0];

        //ShipmentStatus status = sampleStatuses[i % sampleStatuses.length()];

        // Generate dates
        int dayOffset = (i % 30) + 1;
        string createdDate = string `2024-01-${dayOffset.toString().padZero(2)}`;

        int estimatedDays = dayOffset + 3 + (i % 7);
        string? estimatedDeliveryDate = ();
        if estimatedDays <= 31 {
            estimatedDeliveryDate = string `2024-01-${estimatedDays.toString().padZero(2)}`;
        } else {
            int febDay = estimatedDays - 31;
            estimatedDeliveryDate = string `2024-02-${febDay.toString().padZero(2)}`;
        }

        // Generate actual delivery date based on status
        string? actualDeliveryDate = ();
        if status == DELIVERED {
            // For delivered shipments, set actual delivery date
            int actualDays = dayOffset + 2 + (i % 5);
            if actualDays <= 31 {
                actualDeliveryDate = string `2024-01-${actualDays.toString().padZero(2)}`;
            } else {
                int febDay = actualDays - 31;
                actualDeliveryDate = string `2024-02-${febDay.toString().padZero(2)}`;
            }
        } else if status == CANCELLED {
            // For cancelled shipments, set actual delivery date to cancellation date
            int cancelDays = dayOffset + 1 + (i % 3);
            if cancelDays <= 31 {
                actualDeliveryDate = string `2024-01-${cancelDays.toString().padZero(2)}`;
            } else {
                int febDay = cancelDays - 31;
                actualDeliveryDate = string `2024-02-${febDay.toString().padZero(2)}`;
            }
        }
        else if status == PENDING {
            // For cancelled shipments, set actual delivery date to cancellation date
            int cancelDays = dayOffset + 1 + (i % 3);
            if cancelDays <= 31 {
                actualDeliveryDate = string `2024-01-${cancelDays.toString().padZero(2)}`;
            } else {
                int febDay = cancelDays - 31;
                actualDeliveryDate = string `2024-02-${febDay.toString().padZero(2)}`;
            }
        }
        else if status == PROCESSING {
            // For cancelled shipments, set actual delivery date to cancellation date
            int cancelDays = dayOffset + 1 + (i % 3);
            if cancelDays <= 31 {
                actualDeliveryDate = string `2024-01-${cancelDays.toString().padZero(2)}`;
            } else {
                int febDay = cancelDays - 31;
                actualDeliveryDate = string `2024-02-${febDay.toString().padZero(2)}`;
            }
        } else if status == RETURNED {
            // For returned shipments, set actual delivery date to return date
            int returnDays = dayOffset + 4 + (i % 6);
            if returnDays <= 31 {
                actualDeliveryDate = string `2024-01-${returnDays.toString().padZero(2)}`;
            } else {
                int febDay = returnDays - 31;
                actualDeliveryDate = string `2024-02-${febDay.toString().padZero(2)}`;
            }
        } else if status == OUT_FOR_DELIVERY {
            // For out for delivery, set expected delivery date (today or tomorrow)
            int outForDeliveryDays = dayOffset + 3 + (i % 2);
            if outForDeliveryDays <= 31 {
                actualDeliveryDate = string `2024-01-${outForDeliveryDays.toString().padZero(2)}`;
            } else {
                int febDay = outForDeliveryDays - 31;
                actualDeliveryDate = string `2024-02-${febDay.toString().padZero(2)}`;
            }
        } else if status == IN_TRANSIT {
            // For in transit, optionally set expected actual delivery date
            if i % 3 == 0 { // Only for some in-transit shipments
                int transitDays = dayOffset + 2 + (i % 4);
                if transitDays <= 31 {
                    actualDeliveryDate = string `2024-01-${transitDays.toString().padZero(2)}`;
                } else {
                    int febDay = transitDays - 31;
                    actualDeliveryDate = string `2024-02-${febDay.toString().padZero(2)}`;
                }
            }
        }
        // For PENDING and PROCESSING, actualDeliveryDate remains null

        // Generate weight
        decimal totalWeight = <decimal>(1.0 + (i % 50) * 0.1);

        // Generate carrier
        string carrier = sampleCarriers[i % sampleCarriers.length()];

        // Generate tracking number
        string trackingNumber = string `TRK${(1000000000 + i * 12345).toString()}`;

        // Generate products
        Product[] products = [];
        int productCount = (i % 3) + 1; // 1 to 3 products per shipment
        int j = 0;
        while j < productCount {
            string productCode = sampleProductCodes[(i + j) % sampleProductCodes.length()];
            int qty = 10 + ((i + j) % 20) * 5; // Quantities from 10 to 105
            products.push({productCode: productCode, qty: qty});
            j += 1;
        }

        // Create shipment record
        Shipment shipment = {
            shipmentId: shipmentId,
            orderId: orderId,
            customerId: customerId,
            customerName: customerName,
            origin: origin,
            destination: destination,
            status: status,
            createdDate: createdDate,
            estimatedDeliveryDate: estimatedDeliveryDate,
            actualDeliveryDate: actualDeliveryDate,
            totalWeight: totalWeight,
            carrier: carrier,
            trackingNumber: trackingNumber,
            products: products
        };

        shipments[shipmentId] = shipment;
        i += 1;
    }

    return shipments;
}

// Mock shipment data with comprehensive fields (SH001 to SH100)
map<Shipment> mockShipments = generateMockShipments();

// HTTP service for mock shipment API
service /api/v1 on new http:Listener(8081) {

    // Get shipment by ID
    resource function get shipments/[string shipmentId]() returns Shipment|ShipmentNotFound|http:NotFound {
        if mockShipments.hasKey(shipmentId) {
            Shipment shipment = mockShipments.get(shipmentId);
            return shipment;
        } else {
            ShipmentNotFound notFoundResponse = {
                message: "Shipment not found",
                shipmentId: shipmentId
            };
            return notFoundResponse;
        }
    }

    // Update shipment status (PATCH endpoint)
    resource function patch shipments/[string shipmentId](@http:Payload ShipmentStatusUpdateRequest updateRequest) returns ShipmentUpdateResponse|ShipmentUpdateError|http:NotFound|http:InternalServerError {

        // Check if shipment exists in mock data
        if !mockShipments.hasKey(shipmentId) {
            return http:NOT_FOUND;
        }

        // Get current shipment
        Shipment currentShipment = mockShipments.get(shipmentId);

        // Prepare actual delivery date if status is DELIVERED
        string? actualDeliveryDate = ();
        if updateRequest.shipmentStatus == DELIVERED {
            actualDeliveryDate = getCurrentDate();
        }

        // Update mock data - create new record with updated fields
        Shipment updatedShipment = {
            shipmentId: currentShipment.shipmentId,
            orderId: currentShipment.orderId,
            customerId: currentShipment.customerId,
            customerName: currentShipment.customerName,
            origin: currentShipment.origin,
            destination: currentShipment.destination,
            status: updateRequest.shipmentStatus,
            createdDate: currentShipment.createdDate,
            estimatedDeliveryDate: currentShipment.estimatedDeliveryDate,
            actualDeliveryDate: actualDeliveryDate,
            totalWeight: currentShipment.totalWeight,
            carrier: currentShipment.carrier,
            trackingNumber: currentShipment.trackingNumber,
            products: currentShipment.products
        };
        mockShipments[shipmentId] = updatedShipment;

        // Update database
        error? dbUpdateResult = updateShipmentStatusInDb(shipmentId, updateRequest.shipmentStatus, actualDeliveryDate);

        if dbUpdateResult is error {
            // Rollback mock data change
            mockShipments[shipmentId] = currentShipment;

            ShipmentUpdateError errorResponse = {
                message: "Failed to update shipment in database",
                shipmentId: shipmentId,
                errorCode: "DB_UPDATE_FAILED"
            };
            return errorResponse;
        }

        // Return success response
        ShipmentUpdateResponse successResponse = {
            message: "Shipment status updated successfully",
            shipmentId: shipmentId,
            updatedStatus: updateRequest.shipmentStatus,
            actualDeliveryDate: actualDeliveryDate
        };

        return successResponse;
    }

    // Get distinct shipment IDs from database
    resource function get shipments/ids() returns DistinctShipmentIdsResponse|http:InternalServerError {
        string[]|error shipmentIds = getDistinctShipmentIds();

        if shipmentIds is error {
            return http:INTERNAL_SERVER_ERROR;
        }

        DistinctShipmentIdsResponse response = {
            shipmentIds: shipmentIds,
            count: shipmentIds.length()
        };

        return response;
    }

    // POST endpoint to publish invoices
    resource function post invoices(@http:Payload InvoicePublishRequest invoiceRequest) returns InvoicePublishResponse|InvoicePublishError|http:BadRequest|http:InternalServerError {

        // Validate required fields
        if invoiceRequest.customerId.trim() == "" {
            InvoicePublishError errorResponse = {
                message: "Customer ID is required",
                errorCode: "INVALID_CUSTOMER_ID",
                details: "Customer ID cannot be empty"
            };
            return errorResponse;
        }

        if invoiceRequest.customerName.trim() == "" {
            InvoicePublishError errorResponse = {
                message: "Customer name is required",
                errorCode: "INVALID_CUSTOMER_NAME",
                details: "Customer name cannot be empty"
            };
            return errorResponse;
        }

        if invoiceRequest.customerEmail.trim() == "" {
            InvoicePublishError errorResponse = {
                message: "Customer email is required",
                errorCode: "INVALID_CUSTOMER_EMAIL",
                details: "Customer email cannot be empty"
            };
            return errorResponse;
        }

        if invoiceRequest.items.length() == 0 {
            InvoicePublishError errorResponse = {
                message: "At least one invoice item is required",
                errorCode: "NO_INVOICE_ITEMS",
                details: "Invoice must contain at least one item"
            };
            return errorResponse;
        }

        // Validate shipment ID if provided
        if invoiceRequest.shipmentId is string {
            string shipmentId = <string>invoiceRequest.shipmentId;
            if !mockShipments.hasKey(shipmentId) {
                InvoicePublishError errorResponse = {
                    message: "Invalid shipment ID provided",
                    errorCode: "INVALID_SHIPMENT_ID",
                    details: string `Shipment ${shipmentId} not found`
                };
                return errorResponse;
            }
        }

        // Calculate subtotal
        decimal subtotal = 0.0d;
        foreach InvoiceItem item in invoiceRequest.items {
            if item.quantity <= 0 {
                InvoicePublishError errorResponse = {
                    message: "Invalid quantity for invoice item",
                    errorCode: "INVALID_ITEM_QUANTITY",
                    details: string `Product ${item.productCode} has invalid quantity`
                };
                return errorResponse;
            }

            if item.unitPrice < 0.0d {
                InvoicePublishError errorResponse = {
                    message: "Invalid unit price for invoice item",
                    errorCode: "INVALID_UNIT_PRICE",
                    details: string `Product ${item.productCode} has invalid unit price`
                };
                return errorResponse;
            }

            subtotal += item.totalPrice;
        }

        // Calculate total amount
        decimal totalAmount = subtotal + invoiceRequest.taxAmount;

        // Generate invoice ID
        string invoiceId = string `INV${invoiceCounter.toString().padZero(6)}`;
        invoiceCounter += 1;

        // Get current date
        string invoiceDate = getCurrentDate();

        // Create invoice record
        Invoice newInvoice = {
            invoiceId: invoiceId,
            customerId: invoiceRequest.customerId,
            customerName: invoiceRequest.customerName,
            customerEmail: invoiceRequest.customerEmail,
            invoiceDate: invoiceDate,
            dueDate: invoiceRequest.dueDate,
            items: invoiceRequest.items,
            subtotal: subtotal,
            taxAmount: invoiceRequest.taxAmount,
            totalAmount: totalAmount,
            currency: invoiceRequest.currency,
            status: "PUBLISHED",
            shipmentId: invoiceRequest.shipmentId
        };

        // Store invoice in memory
        publishedInvoices[invoiceId] = newInvoice;

        // Return success response
        InvoicePublishResponse successResponse = {
            message: "Invoice published successfully",
            invoiceId: invoiceId,
            customerId: invoiceRequest.customerId,
            totalAmount: totalAmount,
            invoiceDate: invoiceDate
        };

        return successResponse;
    }

    // GET endpoint to retrieve invoice by ID
    resource function get invoices/[string invoiceId]() returns Invoice|http:NotFound {
        if publishedInvoices.hasKey(invoiceId) {
            Invoice invoice = publishedInvoices.get(invoiceId);
            return invoice;
        } else {
            return http:NOT_FOUND;
        }
    }

    // Get NDJSON content (string only) by ID
    resource function get ndjson/content/[int logId]() returns string|http:NotFound|http:InternalServerError {
        string|error ndjsonContent = getNdjsonContentStringById(logId);

        if ndjsonContent is error {
            return http:NOT_FOUND;
        }

        return ndjsonContent;
    }

    // Get NDJSON logs by file name
    resource function get ndjson/logs/filename/[string fileName]() returns NdjsonLogsResponse|http:InternalServerError {
        NdjsonLogRecord[]|error ndjsonLogs = getNdjsonContentByFileName(fileName);

        if ndjsonLogs is error {
            return http:INTERNAL_SERVER_ERROR;
        }

        NdjsonLogsResponse response = {
            logs: ndjsonLogs,
            count: ndjsonLogs.length()
        };

        return response;
    }

}

public function main() returns error? {
    // Service will start automatically when the module is run
}
